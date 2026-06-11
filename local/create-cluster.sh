#!/usr/bin/env bash
set -euo pipefail

# Kind cluster creation script.
# Called by infra/evals/setup-eval.sh and infra/demo/setup-demo.sh.
#
# Flags:
#   --recreate  Destroy any existing cluster before creating (default: skip if already exists)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/export_env.sh"

RECREATE=false
for arg in "$@"; do
  case "$arg" in
    --recreate) RECREATE=true ;;
    *) echo "Unknown flag: $arg"; exit 1 ;;
  esac
done

if kind get clusters 2>/dev/null | grep -q "^${KIND_CLUSTER_NAME}$"; then
  if [ "${RECREATE}" = "false" ]; then
    echo "[~] Reusing existing Kind cluster '${KIND_CLUSTER_NAME}'"
    exit 0
  fi
  echo "[+] Recreating Kind cluster '${KIND_CLUSTER_NAME}'..."
  "${SCRIPT_DIR}/destroy-cluster.sh"
fi

echo ""
echo "[+] Creating kind cluster '${KIND_CLUSTER_NAME}'..."
kind create cluster --name "${KIND_CLUSTER_NAME}" --config "${SCRIPT_DIR}"/kind-config.yaml

echo "[+] Creating internal kubeconfig '${KUBECONFIG}-internal'..."
kind get kubeconfig --name "${KIND_CLUSTER_NAME}" --internal > "${KUBECONFIG}-internal"

echo "[+] Adding helm repos..."
helm repo add cilium https://helm.cilium.io/
helm repo add traefik https://traefik.github.io/charts
helm repo update

echo ""
echo "[+] Installing Cilium CNI..."
CILIUM_IMAGE="quay.io/cilium/cilium:v${CILIUM_VERSION}"
echo "[+] Pulling Cilium image (all platforms for local cache)..."
# Pull all platforms in local cache because kind uses --all-platforms flag when loading images
docker pull --platform=linux/arm64 "${CILIUM_IMAGE}"
docker pull --platform=linux/amd64 "${CILIUM_IMAGE}"
echo "[+] Loading Cilium image into Kind cluster..."
kind load docker-image "${CILIUM_IMAGE}" --name "${KIND_CLUSTER_NAME}"
helm install cilium cilium/cilium --version "${CILIUM_VERSION}" --namespace kube-system \
  --set image.pullPolicy=IfNotPresent --set ipam.mode=kubernetes --set operator.replicas=1 --wait

CONTROL_PLANE_NODE="${KIND_CLUSTER_NAME}-control-plane"
echo "[+] Waiting for ${CONTROL_PLANE_NODE} node to be ready..."
kubectl wait --for=condition=Ready node "${CONTROL_PLANE_NODE}" --timeout=30s

echo ""
echo "[+] Installing Traefik ingress controller..."
# Filter out kubectl "unrecognized format" warnings (harmless, related to OpenAPI schema)
helm install traefik traefik/traefik --create-namespace --namespace traefik \
  --set ports.web.exposedPort=80 --set ports.websecure.exposedPort=443 \
  --set service.type=LoadBalancer 2> >(grep -v "unrecognized format" >&2)

echo "[+] Waiting for Traefik pods to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=traefik -n traefik --timeout=30s

echo "[+] Setting up port forwarding localhost:${INGRESS_PORT} -> traefik:80..."
kubectl port-forward -n traefik service/traefik "${INGRESS_PORT}":80 &

echo ""
echo "[✓] Kind cluster '${KIND_CLUSTER_NAME}' ready"

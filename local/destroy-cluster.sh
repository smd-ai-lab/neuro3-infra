#!/usr/bin/env bash
set -euo pipefail

# Kind cluster teardown script.
# Called by infra/evals/teardown-eval.sh and infra/demo/teardown-demo.sh.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/export_env.sh"

echo "[+] Deleting kind cluster '${KIND_CLUSTER_NAME}'..."
kind delete cluster --name "${KIND_CLUSTER_NAME}"

echo "[+] Removing generated kubeconfig files..."
rm -f "${KUBECONFIG}" "${KUBECONFIG}-internal"

echo "[+] Killing any port-forward processes..."
pkill -f "port-forward.*traefik" || true

echo "✓ Cluster teardown complete"

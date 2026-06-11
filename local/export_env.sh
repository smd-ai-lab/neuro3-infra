#!/usr/bin/env bash
# Environment variables for local deployment

# Source and export root .env file (API keys and secrets)
# Get the directory where THIS script is located (not the calling directory)
# Portable across bash, zsh, and POSIX shells
if [ -n "${BASH_SOURCE[0]}" ]; then
  # bash: use BASH_SOURCE when script is sourced
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
elif [ -n "${ZSH_VERSION:-}" ]; then
  # zsh: use special expansion when script is sourced
  SCRIPT_DIR="$(cd "$(dirname "${(%):-%x}")" && pwd)"
else
  # POSIX fallback: use $0 (may not work correctly when sourced)
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
fi
ENV_FILE="${SCRIPT_DIR}/../../.env"

if [ ! -f "${ENV_FILE}" ]; then
  echo "Error: .env file not found at ${ENV_FILE}"
  echo "Copy .env.example to .env at the project root and fill in your API keys."
  return 1
fi

set -a  # automatically export all variables
source "${ENV_FILE}"
set +a  # turn off automatic export

# Kind and Kubernetes
export KIND_CLUSTER_NAME="eval-agent"
export KUBERNETES_IMAGE_TAG="v1.34.0@sha256:7416a61b42b1662ca6ca89f02028ac133a309a2a30ba309614e8ec94d976dc5a"
export KUBECONFIG_NAME="config-kind-eval-agent"
export KUBECONFIG="${HOME}/.kube/${KUBECONFIG_NAME}"

# CNI and Ingress versions
export CILIUM_VERSION="1.18.3"

# Ingress
export INGRESS_PORT=8086

# MCP service
export KAGENT_TOOLS_VERSION="0.0.12"

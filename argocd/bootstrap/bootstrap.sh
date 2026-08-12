#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

argo_cd_namespace="${ARGO_CD_NAMESPACE:-argocd}"

ensure_namespace() {
    if ! kubectl get namespace "${argo_cd_namespace}" > /dev/null 2>&1; then
        kubectl create namespace "${argo_cd_namespace}"
    fi
}

ensure_argocd() {
    # From the docs: https://argo-cd.readthedocs.io/en/stable/getting_started/#1-install-argo-cd
    kubectl kustomize "${SCRIPT_DIR}/overlays/infra-nodes" \
        | kubectl apply -n "${argo_cd_namespace}" -f - \
        --server-side \
        --force-conflicts
}

ensure_namespace
ensure_argocd
echo "---"
echo
echo "ArgoCD bootstrapped."
echo
echo "Access ArgoCD by running the following command:"
echo "kubectl port-forward svc/argocd-server -n ${argo_cd_namespace} 8080:443"
echo "and accessing: https://localhost:8080/"
echo

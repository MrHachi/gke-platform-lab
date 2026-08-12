# Argo CD setup

## Prerequisites

- GCP project bootstrapped
- GKE cluster deployed
- `kubectl` configured to use GKE clusterq

> See [infrastucture/docs/setup.md](infrastructure/docs/setup.md)

- `argocd` CLI tool installed (setup verification only)

## Procedure

Set the following environment variables:

```bash
# Adjust the values as needed for your project.
export ARGO_CD_NAMESPACE="argocd"
```

Run the idempotent Argo CD bootstrapping script:

```bash
./argocd/scripts/bootstrap.sh
```

## Verify setup

Open a port-forwarding session to Argo CD and access it in the browser using according to the
instructions logged at the end of the bootstrap script.

(Argo CD's initial admin password can be retrieved via: `argocd admin initial-password -n argocd`)

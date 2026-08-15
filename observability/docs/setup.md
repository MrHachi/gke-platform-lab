# Observability stack setup

This project composes the observability stack components in a Helm chart according to the
"App of Apps" Argo CD design pattern.
We're using this instead of an ApplicationSet since this is a single-cluster, single-environment
project.

## Prerequisites

- GKE cluster running
- `kubectl`'s config pointed at GKE
- Argo CD set up

> See [infrastucture/docs/setup.md](infrastructure/docs/setup.md)
> See [argocd/docs/setup.md](argocd/docs/setup.md)

## Procedure

Apply the App of Apps's `root.yml`:

```bash
kubectl apply -f observability/root.yml
```

## Verify setup

TODO

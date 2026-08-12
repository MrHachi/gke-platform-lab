# ADR 3: Disable GKE Managed Metric Collection

## Context

The GKE cluster is intentionally provisioned with very small nodes to minimize running cost.

GKE's managed kube-state-metrics deployment consumes resources on the cluster while providing
Kubernetes object-state metrics.
These metrics are useful for monitoring, but the additional resource consumption is significant
relative to the capacity of the `e2-small` application nodes.

The cluster will operate its own observability stack and does not require GKE to independently
provide kube-state-metrics.

## Decision

The GKE managed kube-state-metrics package will be disabled.

If Kubernetes object-state metrics are required, kube-state-metrics will instead be deployed as
part of the lab's self-managed observability stack.

## Consequences

### Positive

- Reduces baseline CPU and memory requests on the cluster
- Frees capacity on the small application nodes
- Avoids duplicating kube-state-metrics functionality between GKE and the lab's observability stack
- Gives the lab direct control over the resource requirements and configuration of kube-state-metrics

### Negative

- Kubernetes object-state metrics will no longer be available from the GKE-managed deployment
- If these metrics are required later, the lab must deploy and operate kube-state-metrics itself
- The observability stack acquires another component to maintain

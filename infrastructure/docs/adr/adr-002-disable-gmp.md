# ADR 002: Disable Google Managed Service for Prometheus

## Context

This lab's GKE cluster is designed for small-scale personal use and consists of one
`e2-medium` infrastructure node and two `e2-small` application nodes.
Google Managed Service for Prometheus (GMP) deploys additional metric collection
infrastructure into the cluster.
These components consume CPU and memory resources that are significant relative to the
available capacity of the `e2-small` application nodes.

Given that the purpose of this cluster is to gain practical experience operating Kubernetes
infrastructure, including observability components, we would benefit more from operating
our own Prometheus instance rather than relying on a managed collection service.

## Decision

Google Managed Service for Prometheus will be disabled for this cluster.
Prometheus will instead be deployed and operated as a normal Kubernetes workload when
metrics collection is required.
The self-managed Prometheus deployment will be responsible for its own configuration, resource
requests, storage, retention, and lifecycle.

## Consequences

### Positive

- Reduces the baseline resource consumption of the cluster
- Frees application-node capacity for workloads being used to exercise Kubernetes scheduling
- Provides practical experience operating Prometheus within Kubernetes
- Gives the lab direct control over Prometheus resource requests and configuration
- Avoids operating two independent metrics systems unnecessarily

### Negative

- Prometheus becomes another workload that must be operated and maintained
- Metrics availability depends on the health of the lab's own Prometheus deployment
- Google-managed Prometheus functionality will not be available unless it is re-enabled

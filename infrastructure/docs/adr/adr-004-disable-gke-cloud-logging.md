# ADR 4: Disable GKE Cloud Logging

## Context

GKE enables managed logging infrastructure that runs within the cluster and consumes node
resources.
This lab is intended to operate its own logging infrastructure using Loki. Running both GKE Cloud
Logging and Loki would result in duplicated log collection and additional resource consumption on
a cluster with very limited capacity.

Production-grade operational support/long-term centralized logging are out of scope for this
personal lab.

## Decision

GKE Cloud Logging will be disabled for the cluster.

Application and Kubernetes logs will instead be collected by the lab's self-managed logging stack,
with Loki serving as the primary log storage and query system.

## Consequences

### Positive

- Reduces baseline resource consumption from the GKE logging agent
- Frees capacity for application and infrastructure workloads
- Avoids duplicating log collection through both GKE Cloud Logging and Loki
- Provides practical experience operating Kubernetes logging infrastructure
- Gives the lab direct control over log collection and retention

### Negative

- Logs will no longer be available through Google Cloud's managed logging infrastructure
- Troubleshooting the cluster will rely on the lab's own logging infrastructure and direct Kubernetes inspection
- The lab assumes responsibility for operating and maintaining its logging pipeline
- Google Cloud support has less managed diagnostic information available for the cluster

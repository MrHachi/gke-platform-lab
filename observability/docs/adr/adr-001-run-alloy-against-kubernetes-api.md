# ADR 1: Run Alloy against the Kubernetes API

## Context

Alloy supports ingesting logs directly from node filesystems as well as obtaining them
through the Kubernetes API.

With the former option, Alloy would need to run on every node from which we want to
collect logs, typically by deploying it as a DaemonSet.

The latter allows Alloy replicas to be scheduled independently of the nodes producing
the logs, but introduces additional API/kubelet and network overhead.

## Decision

This lab is running on four very small nodes. It can only support a limited number of
workloads, and scheduling is constrained by CPU requests.

We therefore want to avoid requiring an Alloy instance on every node where possible.
The expected log volume is also very small (well under 1 GB/day), making the additional
overhead of collecting logs through Kubernetes acceptable.

We will therefore configure Alloy to obtain Kubernetes container logs through the
Kubernetes API rather than reading log files directly from nodes.

## Consequences

### Positive

- Alloy can be scheduled independently of the nodes producing logs
- Alloy can be scaled independently of cluster node count
- Avoids requiring an Alloy instance on every node
- Reduces cluster-wide CPU request consumption

### Negative

- Introduces additional load on the Kubernetes API/kubelets
- Introduces additional network and processing overhead for log ingestion
- Adds another dependency on Kubernetes API availability for log collection

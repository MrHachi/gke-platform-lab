# core: platform

![platform stack architecture diagram](/infrastructure/docs/diagrams/platform.drawio.svg)

## Purpose

Manage the foundational infrastructure, including GKE and LoadBalancers, for the gke-platform-lab project.

## Destructive changes

- [network](/infrastructure/stacks/network) stack changes changes may affect these resources catastrophically
- Zone/region changes will result in GKE resources being recreated

# gke-platform-lab infrastructure

Contains the OpenTofu / Terraform modules and stacks required to deploy a small zonal GKE cluster.

```text

infrastructure/
  │
  ├─ stacks/    <- stack code
  │
  ├─ modules/   <- modules consumed by the above
  │
  └─ scripts/   <- one-off scripts for bootstrapping environment for OpenTofu

```

## Constraints

- Each stack has an independent state file and backend prefix
- GKE consumes subnet secondary ranges from the network stack state
- Modifying subnet secondary ranges used by GKE requires recreation of the GKE cluster
    - The subnet may also need to be recreated depending on the change.
- Network state is intentionally long-lived and **not** managed by CI/CD (applied manually)
    - This is to reduce the blast radius of accidental CI/CD changes
- Apply order: network → platform
- Destroy order: platform → network
- The repo structure and remote-state references are the authoritative dependency graph
- Stacks consume dependency stack outputs exclusively through `terraform_remote_state`; direct references between stacks are not permitted

## `core` stacks

- [network](/infrastructure/stacks/network)
- [platform](/infrastructure/stacks/platform)

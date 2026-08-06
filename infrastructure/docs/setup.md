# Environment setup

## OpenTofu / Terraform

### Prerequisites

- OpenTofu or Terraform executable
- gcloud CLI

### Procedure

> Assumes no GCP organization

Set the following environment variables:

```bash
GCLOUD_PROJECT="{GCP project ID (default: gke-platform-lab)}"
GCLOUD_REGION="{GCP region (default: us-south1)}"
GCLOUD_BILLING_ACCOUNT="{billing account ID}"
REPO_NAME="{GitHub repository for CI/CD)}"
REPO_OWNER="{GitHub repository owner}"
```

Run:

```bash
./infrastructure/scripts/bootstrap.sh
```

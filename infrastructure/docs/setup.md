# Environment setup

## OpenTofu / Terraform

### Prerequisites

- OpenTofu installed and executable
- gcloud CLI

### Procedure

> Assumes the GCP project is not attached to a Google Cloud Organization and that you have permission to create service accounts,
> IAM bindings, Workload Identity Federation resources, and GCS buckets.

Set the following environment variables:

```bash
# Adjust the values as needed for your project.
export GCLOUD_PROJECT="gke-platform-lab"
export GCLOUD_REGION="us-south1"
export GCLOUD_BILLING_ACCOUNT="000000-000000-000000"
export REPO_NAME="my-repo"
export REPO_OWNER="my-github-user"
```

Run the idempotent environment bootstrapping script:

```bash
./infrastructure/scripts/bootstrap.sh
```

> Save the values printed at the end of the script; they are required for the GitHub Actions configuration.

## GitHub

- [CI](./cicd.md#tf-stack-ci): PR to main
- [CD](./cicd.md#tf-stack-cd): PR is merged (or on any push to main)
    - saves a tfplan file to GCS for later execution
- [Deployment](./cicd.md#tf-stack-deploy): tag push (pattern: `platform/v*`)
    - the plan saved above in CD is executed

### Procedure

Set the following repository variables for GitHub Actions:

- `GCLOUD_PROJECT`: {GCP project ID}
- `GCLOUD_PROVIDER`: {GCP OIDC provider ID}
    - taken from the output at the end of the `bootstrap.sh` script (`provider`)
- `PLAN_SA`: {Service account used for Tofu plan}
    - taken from the output at the end of the `bootstrap.sh` script (`plan-account`)
- `APPLY_SA`: {Service account used for Tofu apply}
    - taken from the output at the end of the `bootstrap.sh` script (`apply-account`)
- `ARTIFACT_SA`: {Service account used to upload the tfplan file to GCS during CD}
    - taken from the output at the end of the `bootstrap.sh` script (`artifact-account`)
- `TFSTATE_BUCKET`: {GCS bucket name used for tfstate and tfplan files}
    - taken from the output at the end of the `bootstrap.sh` script (`terraform-backend.bucket`)
- `ARTIFACT_PREFIX`: {Prefix in the GCS bucket under which to store tfplan files}
    - taken from the output at the end of the `bootstrap.sh` script (`terraform-backend.artifact-prefix`)

> As this is a lab project, we aren't setting these in specific environments.
> In a production setting it would likely be preferable to separate configuration between `dev`, `stg`, and `prd`.

# Setup verification

1. Cut a branch from main
2. Modify any of the files under `infrastructure/stacks`
3. Open a PR to main
4. Verify that the `tf-stack-ci` workflow runs and that plan results are commented on the PR

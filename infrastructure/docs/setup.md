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

### Verify setup

1. Cut a branch from main
2. Modify any of the files under `infrastructure/stacks`
3. Open a PR to main
4. Verify that the `tf-stack-ci` workflow runs and that plan results are commented on the PR

## GKE Cluster

### Prerequisites

- GCP Project and GitHub bootstrapped according to the procedures above

### Procedure

1. Deploy the network stack (managed manually):
    ```bash
    cd infrastructure/stacks/network
    tofu plan -out=tfplan # Review plan before proceeding
    tofu apply tfplan
    ```
2. In GitHub Actions, run the `TF Stack CD` workflow manually (or merge a PR that contains changes under `infrastructure/stacks/platform`)
3. Pull the latest version of the `main` branch
4. Tag the current commit with the pattern `platform-v**` (i.e. `platform-v0.0.1`)
5. Push the tag to the remote

### Post setup

1. Ensure the `gke-gcloud-auth-plugin` gcloud plugin is installed
    ```bash
    gcloud components install gke-gcloud-auth-plugin
    ```
2. Log in
    ```bash
    gcloud auth login
    ```
3. Set project:
    ```bash
    gcloud config set project {BOOTSTRAPPED_PROJECT}
    ```
4. Authenticate with GKE:
    - This lab uses a zonal GKE cluster for savings
    - OpenTofu creates it in the `us-south1-a` zone
    ```bash
    gcloud container clusters get-credentials lab-platform-gke --zone {CLUSTER_ZONE}
    ```

### Verify setup

```bash
kubectl get nodes
```

## Quotas

Node pool Kubernetes version updates will fail due to the regional quota being stuck at 500GB.
(This lab creates a 4 node cluster, with each node requesting 100GB of SSD-updates will push this
past 500GB and cause an error.)

### Prerequisites

- `bootstrap.sh` script executed (enables the `cloudquotas.googleapis.com` API)

### Procedure

Log in to the GCP console and increase the **Persistent Disk SSD (GB)** quota for the
**Compute Engine API** service in your region to 1000GB.

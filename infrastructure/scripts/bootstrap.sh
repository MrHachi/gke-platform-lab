#!/usr/bin/env bash
set -euo pipefail

project_id="${GCLOUD_PROJECT:-gke-platform-lab}"
project_number=$(gcloud projects describe "${project_id}" --format="value(projectNumber)")
region="${GCLOUD_REGION:-us-south1}"

: "${GCLOUD_BILLING_ACCOUNT:?GCLOUD_BILLING_ACCOUNT must be set}"
: "${REPO_OWNER:?REPO_OWNER must be set}"
: "${REPO_NAME:?REPO_NAME must be set}"

billing_account_id="${GCLOUD_BILLING_ACCOUNT}"
repo_owner="${REPO_OWNER}"
repo_name="${REPO_NAME}"

WORKLOAD_IDENTITY_POOL_NAME="github-actions-pool"
PROVIDER_NAME="github-actions-id-provider"
SERVICE_ACCOUNT_NAME_BASE="github-actions"

plan_account_name="${SERVICE_ACCOUNT_NAME_BASE}-plan"
apply_account_name="${SERVICE_ACCOUNT_NAME_BASE}-apply"
artifact_account_name="${SERVICE_ACCOUNT_NAME_BASE}-artifacts"
plan_sa="${plan_account_name}@${project_id}.iam.gserviceaccount.com"
apply_sa="${apply_account_name}@${project_id}.iam.gserviceaccount.com"
artifact_sa="${artifact_account_name}@${project_id}.iam.gserviceaccount.com"

bucket="${project_id}-tfstate"
core_state_prefix="state/core/"
core_artifact_prefix="artifacts/core/"


gcloud auth login
echo "Using project-id: ${project_id}"

ensure_project() {
    echo "Ensure project: ${project_id}"
    gcloud projects describe "${project_id}" > /dev/null 2>&1 || \
        gcloud projects create "${project_id}"
}

ensure_billing() {
    echo "Ensure billing set on project: ${project_id}"
    current_billing=$(gcloud billing projects describe "${project_id}" \
      --format="value(billingAccountName)")

    if [ "${current_billing}" != "billingAccounts/${billing_account_id}" ]; then
        gcloud billing projects link "${project_id}" --billing-account="${billing_account_id}"
    fi
}

ensure_apis() {
    echo "Ensure APIs"
    gcloud services enable \
        container.googleapis.com \
        compute.googleapis.com \
        iam.googleapis.com \
        iamcredentials.googleapis.com \
        cloudresourcemanager.googleapis.com \
        storage.googleapis.com \
        --project "${project_id}"
}

ensure_github_actions_oidc() {
    echo "Ensure OIDC"

    echo "workload-identity-pool: ${WORKLOAD_IDENTITY_POOL_NAME}"
    gcloud iam workload-identity-pools describe --location="global" "${WORKLOAD_IDENTITY_POOL_NAME}" > /dev/null 2>&1 || \
        gcloud iam workload-identity-pools create "${WORKLOAD_IDENTITY_POOL_NAME}" \
            --project="${project_id}" \
            --location="global"

    echo "provider: ${PROVIDER_NAME}"
    gcloud iam workload-identity-pools providers describe "${PROVIDER_NAME}" \
        --location="global" \
        --workload-identity-pool="${WORKLOAD_IDENTITY_POOL_NAME}" > /dev/null 2>&1 || \
        gcloud iam workload-identity-pools providers create-oidc "${PROVIDER_NAME}" \
            --project="${project_id}" \
            --location="global" \
            --workload-identity-pool="${WORKLOAD_IDENTITY_POOL_NAME}" \
            --issuer-uri="https://token.actions.githubusercontent.com" \
            --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository,attribute.repository_owner=assertion.repository_owner" \
            --attribute-condition="assertion.repository_owner == '${REPO_OWNER}'"
}

ensure_service_accounts() {
    echo "Ensure OpenTofu service accounts"

    echo "${plan_account_name}" ; \
    gcloud iam service-accounts describe "${plan_sa}" --project="${project_id}" > /dev/null 2>&1 || \
        gcloud iam service-accounts create "${plan_account_name}" \
            --project="${project_id}"

    echo "${apply_account_name}" ; \
    gcloud iam service-accounts describe "${apply_sa}" --project="${project_id}" > /dev/null 2>&1 || \
        gcloud iam service-accounts create "${apply_account_name}" \
            --project="${project_id}"

    echo "${artifact_account_name}" ; \
    gcloud iam service-accounts describe "${artifact_sa}" --project="${project_id}" > /dev/null 2>&1 || \
        gcloud iam service-accounts create "${artifact_account_name}" \
            --project="${project_id}"

    echo "${plan_account_name} policy-binding" ; \
    gcloud iam service-accounts add-iam-policy-binding "${plan_sa}" \
        --project="${project_id}" \
        --role="roles/iam.workloadIdentityUser" \
        --member="principalSet://iam.googleapis.com/projects/${project_number}/locations/global/workloadIdentityPools/${WORKLOAD_IDENTITY_POOL_NAME}/attribute.repository/${repo_owner}/${repo_name}"

    echo "${apply_account_name} policy-binding" ; \
    gcloud iam service-accounts add-iam-policy-binding "${apply_sa}" \
        --project="${project_id}" \
        --role="roles/iam.workloadIdentityUser" \
        --member="principalSet://iam.googleapis.com/projects/${project_number}/locations/global/workloadIdentityPools/${WORKLOAD_IDENTITY_POOL_NAME}/attribute.repository/${repo_owner}/${repo_name}"

    echo "${artifact_account_name} policy-binding" ; \
    gcloud iam service-accounts add-iam-policy-binding "${artifact_sa}" \
        --project="${project_id}" \
        --role="roles/iam.workloadIdentityUser" \
        --member="principalSet://iam.googleapis.com/projects/${project_number}/locations/global/workloadIdentityPools/${WORKLOAD_IDENTITY_POOL_NAME}/attribute.repository/${repo_owner}/${repo_name}"
}

ensure_state_bucket() {
    echo "Ensure state bucket: ${bucket}"
    if ! gcloud storage buckets describe "gs://${bucket}" >/dev/null 2>&1; then
        gcloud storage buckets create "gs://${bucket}" \
            --project="${project_id}" \
            --location="${region}" \
            --uniform-bucket-level-access
    fi

    gcloud storage buckets update "gs://${bucket}" --versioning
}

ensure_state_bucket_permissions() {
    echo "Ensure state bucket permissions"

    echo "${plan_sa}"
    gcloud storage buckets add-iam-policy-binding "gs://${project_id}-tfstate" \
        --member="serviceAccount:${plan_sa}" \
        --role="roles/storage.objectViewer" \
        --condition="title=State prefix access,expression=resource.name.startsWith('projects/_/buckets/${bucket}/objects/${core_state_prefix}')"

    echo "${apply_sa}"
    gcloud storage buckets add-iam-policy-binding "gs://${project_id}-tfstate" \
        --member="serviceAccount:${apply_sa}" \
        --role="roles/storage.objectAdmin" \
        --condition="title=State prefix access,expression=resource.name.startsWith('projects/_/buckets/${bucket}/objects/${core_state_prefix}')"

    echo "${artifact_sa}"
    gcloud storage buckets add-iam-policy-binding "gs://${project_id}-tfstate" \
        --member="serviceAccount:${artifact_sa}" \
        --role="roles/storage.objectUser" \
        --condition="title=Artifact prefix access,expression=resource.name.startsWith('projects/_/buckets/${bucket}/objects/${core_artifact_prefix}')"
}

ensure_iac_permissions() {
    echo "Ensure OpenTofu/Terraform permissions"

    # Plan account (read-only)
    gcloud projects add-iam-policy-binding "${project_id}" \
        --member="serviceAccount:${plan_sa}" \
        --role="roles/viewer"

    # Apply account (sufficient for this lab)
    for role in \
        roles/container.admin \
        roles/compute.admin \
        roles/iam.serviceAccountAdmin \
        roles/iam.serviceAccountUser \
        roles/resourcemanager.projectIamAdmin \
        roles/storage.admin
        do
            gcloud projects add-iam-policy-binding "${project_id}" \
            --member="serviceAccount:${apply_sa}" \
            --role="${role}"
    done
}


ensure_project
ensure_billing
ensure_apis

ensure_github_actions_oidc
ensure_service_accounts

ensure_state_bucket
ensure_state_bucket_permissions
ensure_iac_permissions

# Output values necessary for GHA
echo "---"
echo
echo "provider: projects/${project_number}/locations/global/workloadIdentityPools/${WORKLOAD_IDENTITY_POOL_NAME}/providers/${PROVIDER_NAME}"
echo
echo "plan-account: ${plan_sa}"
echo
echo "apply-account: ${apply_sa}"
echo
echo "artifact-account: ${artifact_sa}"
echo
echo "terraform-backend:"
echo "  bucket: \"${bucket}\""
echo "  state-prefix: \"${core_state_prefix}\""
echo "  artifact-prefix: \"${core_artifact_prefix}\""

locals {
  module = "sa"
}

data "google_project" "current" {}

resource "google_service_account" "main" {
  account_id   = var.id
  display_name = var.display_name
  description  = var.description
}

resource "google_service_account_iam_member" "gke_assume" {
  service_account_id = google_service_account.main.name
  role               = "roles/iam.workloadIdentityUser"

  member = "serviceAccount:${data.google_project.current.project_id}.svc.id.goog[${var.workload_namespace}/${var.workload_sa}]"
}

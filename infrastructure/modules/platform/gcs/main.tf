locals {
  module = "gcs"

  bucket_name = "${var.stack}-${var.name_base}-${data.google_project.current.number}"
}

data "google_project" "current" {}

resource "google_storage_bucket" "main" {
  name     = local.bucket_name
  location = var.location

  uniform_bucket_level_access = true
  storage_class               = "STANDARD"
  public_access_prevention    = "enforced"

  dynamic "lifecycle_rule" {
    for_each = var.object_expiry != null ? [1] : []
    content {
      condition {
        age = var.object_expiry.days
      }

      action {
        type = "Delete"
      }
    }
  }

  labels = {
    stack  = var.stack
    module = local.module
  }
}

resource "google_storage_bucket_iam_member" "member" {
  for_each = var.accessors

  bucket = google_storage_bucket.main.name
  member = each.key
  role   = each.value.role

  dynamic "condition" {
    for_each = each.value.condition != null ? [1] : []
    content {
      title       = each.value.condition.title
      description = each.value.condition.description
      expression  = each.value.condition.expression
    }
  }
  timeouts {
    create = "5m"
  }
}

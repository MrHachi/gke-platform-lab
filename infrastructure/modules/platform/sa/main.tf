locals {
  module = "sa"
}

resource "google_service_account" "main" {
  account_id   = var.id
  display_name = var.display_name
  description  = var.description
}

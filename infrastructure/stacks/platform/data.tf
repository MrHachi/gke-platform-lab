data "terraform_remote_state" "network" {
  backend = "gcs"
  config = {
    bucket = "gke-platform-lab-tfstate"
    prefix = "state/core/network"
  }
}

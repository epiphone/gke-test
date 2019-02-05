locals {
  env = "dev"
}

terraform {
  required_version = "0.11.11"

  backend "gcs" {
    bucket = "tf-state-gke-dev"
    prefix = "terraform-state-dev"
  }
}

provider "google" {
  version = "1.20.0"

  project = "${var.project_id}"
  region  = "${var.region}"
  zone    = "${var.zone}"
}

provider "google-beta" {
  version = "1.20.0"

  project = "${var.project_id}"
  region  = "${var.region}"
  zone    = "${var.zone}"
}

module "gke" {
  source = "../modules/gke"

  env          = "${local.env}"
  region       = "${var.region}"
  network_name = "gke-network"
}

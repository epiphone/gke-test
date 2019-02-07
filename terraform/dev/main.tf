locals {
  env = "dev"
}

terraform {
  required_version = "0.11.11"

  backend "gcs" {
    bucket = "gke-tfstate-dev"
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

  env                   = "${local.env}"
  region                = "${var.region}"
  network_name          = "gke-network"
  k8s_master_allowed_ip = "${var.k8s_master_allowed_ip}"
}

module "cloud_sql" {
  source = "../modules/cloud_sql"

  network  = "${module.gke.network}"
  region   = "${var.region}"
  db_name  = "gke-${local.env}"
  username = "gke-${local.env}"
  password = "${var.db_password}"
}

module "backend_bucket" {
  source = "../modules/backend_bucket"

  location = "${var.region}"
}

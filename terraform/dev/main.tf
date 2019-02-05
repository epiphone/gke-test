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

resource "google_project_services" "project" {
  project = "${var.project_id}"

  services = [
    "cloudapis.googleapis.com",
    "clouddebugger.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudtrace.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "containeranalysis.googleapis.com",
    "containerregistry.googleapis.com",
    "datastore.googleapis.com",
    "dns.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "oslogin.googleapis.com",
    "pubsub.googleapis.com",
    "servicemanagement.googleapis.com",
    "servicenetworking.googleapis.com",
    "serviceusage.googleapis.com",
    "sql-component.googleapis.com",
    "storage-api.googleapis.com",
    "storage-component.googleapis.com",
  ]
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

  network = "${module.gke.network}"
}

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
  project = "${var.project_id}"
  region  = "${var.region}"
  zone    = "${var.zone}"
}

module "gke" {
  source = "../modules/gke"

  env = "${local.env}"
}

module "k8s" {
  source = "../modules/k8s"

  env                    = "${local.env}"
  host                   = "${module.gke.host}"
  client_certificate     = "${module.gke.client_certificate}"
  client_key             = "${module.gke.client_key}"
  cluster_ca_certificate = "${module.gke.cluster_ca_certificate}"
  app_image_tag          = "${var.app_image_tag}"
}

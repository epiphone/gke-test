data "google_container_engine_versions" "gke_versions" {}

resource "google_compute_network" "gke_network" {
  name                    = "${var.network_name}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "gke_subnetwork" {
  name                     = "${var.network_name}"
  ip_cidr_range            = "10.127.0.0/20"
  network                  = "${google_compute_network.gke_network.self_link}"
  region                   = "${var.region}"
  private_ip_google_access = true
}

resource "google_container_cluster" "gke_cluster" {
  min_master_version       = "${data.google_container_engine_versions.gke_versions.latest_master_version}"
  name                     = "gke-cluster-${var.env}"
  network                  = "${google_compute_network.gke_network.name}"
  subnetwork               = "${google_compute_subnetwork.gke_subnetwork.name}"
  remove_default_node_pool = true

  # Use ABAC until official Kubernetes plugin supports RBAC.
  enable_legacy_abac = "true"

  ip_allocation_policy {} # Enable alias IP addresses https://cloud.google.com/kubernetes-engine/docs/how-to/alias-ips

  lifecycle {
    ignore_changes = ["node_pool"]
  }

  node_pool {
    name = "default-pool"
  }
}

resource "google_container_node_pool" "gke_pool" {
  name       = "gke-pool-${var.env}"
  cluster    = "${google_container_cluster.gke_cluster.name}"
  node_count = "1"

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    disk_size_gb = 10
    machine_type = "n1-standard-1"
  }
}

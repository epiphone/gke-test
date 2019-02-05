# TODO use another VPC for db?
# resource "google_compute_network" "private_network" {
#     name       = "private_network"
# }

resource "google_compute_global_address" "private_ip_address" {
  provider      = "google-beta"
  name          = "cloud_sql_private_ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = "${var.network}"
}

resource "google_service_networking_connection" "private_vpc_connection" {
  provider                = "google-beta"
  network                 = "${var.network}"
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = ["${google_compute_global_address.private_ip_address.name}"]
}

resource "google_sql_database_instance" "instance" {
  provider   = "google"
  depends_on = ["google_service_networking_connection.private_vpc_connection"]
  name       = "gke_private_instance"

  settings {
    tier = "db-f1-micro"

    ip_configuration {
      ipv4_enabled    = "false"
      private_network = "${var.network}"
    }
  }
}

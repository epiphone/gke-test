resource "google_storage_bucket" "assets" {
  name          = "${var.name}"
  location      = "${var.location}"
  storage_class = "${var.storage_class}"
}

resource "google_storage_bucket_acl" "assets" {
  bucket         = "${google_storage_bucket.assets.name}"
  predefined_acl = "publicRead"
}

resource "google_compute_backend_bucket" "assets" {
  name        = "${var.name}-backend"
  description = "GKE sample app static resources backend"
  bucket_name = "${google_storage_bucket.assets.name}"
  enable_cdn  = true
}

resource "google_compute_url_map" "assets" {
  name        = "${var.name}-map"
  description = "URL map for the assets backend bucket"

  default_service = "${google_compute_backend_bucket.assets.self_link}"

  # TODO add test
  # test {
  #   service = "${google_compute_backend_bucket.assets.self_link}"
  #   host    = "hi.com"
  #   path    = "/index.html"
  # }
}

resource "google_compute_target_http_proxy" "assets" {
  name    = "${var.name}-proxy"
  url_map = "${google_compute_url_map.assets.self_link}"
}

resource "google_compute_global_forwarding_rule" "assets" {
  name       = "${var.name}-rule"
  target     = "${google_compute_target_http_proxy.assets.self_link}"
  port_range = "80"
}

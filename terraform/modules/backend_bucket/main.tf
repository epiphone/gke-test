resource "google_storage_bucket" "assets_bucket" {
  name          = "${var.name}"
  location      = "${var.location}"
  storage_class = "${var.storage_class}"
}

resource "google_storage_bucket_acl" "assets_bucket_acl" {
  bucket         = "${google_storage_bucket.assets_bucket.name}"
  predefined_acl = "publicRead"
}

resource "google_compute_backend_bucket" "assets_backend" {
  name        = "${var.name}-backend"
  description = "GKE sample app static resources backend"
  bucket_name = "${google_storage_bucket.assets_bucket.name}"
  enable_cdn  = true
}

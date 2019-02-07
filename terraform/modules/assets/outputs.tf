output "url" {
  description = "Base URL of the assets bucket"
  value       = "${google_storage_bucket.assets.url}"
}

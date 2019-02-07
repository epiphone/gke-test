output "cluster_name" {
  value = "${module.gke.cluster_name}"
}

output "cluster_zone" {
  value = "${module.gke.cluster_zone}"
}

output "k8s_master_allowed_ip" {
  value = "${var.k8s_master_allowed_ip}"
}

output "db_host" {
  value = "${module.cloud_sql.host}"
}

output "db_name" {
  value = "${module.cloud_sql.db_name}"
}

output "db_username" {
  value = "${module.cloud_sql.username}"
}

output "db_password" {
  value     = "${module.cloud_sql.password}"
  sensitive = true
}

output "project_id" {
  value = "${var.project_id}"
}

output "static_assets_public_address" {
  value = "${module.assets.public_address}"
}

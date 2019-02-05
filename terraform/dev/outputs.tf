output "cluster_name" {
  value = "${module.gke.cluster_name}"
}

output "cluster_zone" {
  value = "${module.gke.cluster_zone}"
}

output "k8s_master_allowed_ip" {
  value = "${var.k8s_master_allowed_ip}"
}

variable "project_id" {
  type    = "string"
  default = "gke-dev-230012"
}

variable "region" {
  type    = "string"
  default = "europe-north1"
}

variable "zone" {
  type    = "string"
  default = "europe-north1-a"
}

variable "k8s_master_allowed_ip" {
  type        = "string"
  description = "Kubernetes cluster master's external IP is only accessible from this IP"
}

variable "db_password" {
  type = "string"
}

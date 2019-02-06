variable "network" {
  type = "string"
}

variable "db_name" {
  default     = "gke"
  description = "Database name"
  type        = "string"
}

variable "username" {
  default = "gke"
  type    = "string"
}

variable "password" {
  type = "string"
}

variable "region" {
  type = "string"
}

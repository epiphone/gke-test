output "connection_name" {
  value = "${google_sql_database_instance.instance.connection_name}"
}

output "host" {
  value = "${google_sql_database_instance.instance.ip_address}"
}

output "username" {
  value = "${google_sql_user.app_user.name}"
}

output "password" {
  value     = "${google_sql_user.app_user.password}"
  sensitive = true
}

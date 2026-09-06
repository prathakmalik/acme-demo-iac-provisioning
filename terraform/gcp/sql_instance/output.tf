# Output Variables

output "db_instance_details" {
  description = "Structural configuration and access metrics for the new GCP SQL instance"
  value = jsonencode({
    instance_id       = google_sql_database_instance.sql_instance.id
    instance_endpoint = google_sql_database_instance.sql_instance.connection_name
    # google_sql_database_instance.db.private_ip_address
    instance_port = 3306
    username      = google_sql_user.root_user.name
    password      = google_sql_user.root_user.password
  })
  sensitive = true
}

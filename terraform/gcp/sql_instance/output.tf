# Output Variables

output "gcp_db_instance_details" {
    description = "Structural configuration and access metrics for the new GCP SQL instance"
    value = {
        sql_instance_name = google_sql_database_instance.sql_instance.name
        sql_instance_arn  = google_sql_database_instance.sql_instance.id
        sql_instance_dns  = google_sql_database_instance.sql_instance.connection_name
        region            = google_sql_database_instance.sql_instance.region
    }
}

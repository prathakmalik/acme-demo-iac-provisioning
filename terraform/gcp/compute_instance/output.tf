# Output Variables

output "db_instance_details" {
    description = "Structural configuration and access metrics for the new GCP SQL instance"
    value = jsonencode({
        instance_id = google_compute_instance.demo_instance.id
        instance_endpoint = google_compute_instance.demo_instance.network_interface[0].access_config[0].nat_ip
        instance_port = 3306
        username = "NOT REQUIERD FOR OS LOGIN"
        password = "NOT REQUIERD FOR OS LOGIN"
    })
    sensitive = true
}


# Output Variables

output "compute_instance_details" {
    description = "Structural configuration and access metrics for the new GCP Compute instance"
    value = jsonencode({
        login_user = "NOT REQUIRED FOR OS LOGIN"
        instance_id = google_compute_instance.demo_instance.id
        instance_name = google_compute_instance.demo_instance.name
        public_ip = google_compute_instance.demo_instance.network_interface[0].access_config[0].nat_ip
        private_ip = google_compute_instance.demo_instance.network_interface[0].network_ip
    })
    sensitive = true
}


# Output Variables

output "instance_details" {
    description = "Key networking details for the web server"
    value = {
        instance_id = aws_instance.ec2_instance.id
        public_ip   = aws_instance.ec2_instance.public_ip
        private_ip  = aws_instance.ec2_instance.private_ip
    }
}

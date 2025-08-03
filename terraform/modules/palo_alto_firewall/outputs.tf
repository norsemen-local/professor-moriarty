output "firewall_id" {
  description = "ID of the Palo Alto Networks firewall instance"
  value       = aws_instance.palo_alto_firewall.id
}

output "private_ip" {
  description = "Private IP address of the firewall"
  value       = aws_instance.palo_alto_firewall.private_ip
}

output "public_ip" {
  description = "Public IP address of the firewall"
  value       = aws_instance.palo_alto_firewall.public_ip
}

output "management_interface_id" {
  description = "ID of the management network interface"
  value       = aws_network_interface.management.id
}

output "trust_interface_id" {
  description = "ID of the trust network interface"
  value       = aws_network_interface.trust.id
}

output "untrust_interface_id" {
  description = "ID of the untrust network interface"
  value       = aws_network_interface.untrust.id
}

output "security_group_id" {
  description = "ID of the firewall security group"
  value       = aws_security_group.palo_alto.id
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group for firewall logs"
  value       = aws_cloudwatch_log_group.palo_alto_logs.name
} 
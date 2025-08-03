output "instance_id" {
  description = "ID of the Linux server instance"
  value       = aws_instance.linux_server.id
}

output "private_ip" {
  description = "Private IP address of the Linux server"
  value       = aws_instance.linux_server.private_ip
}

output "public_ip" {
  description = "Public IP address of the Linux server"
  value       = aws_instance.linux_server.public_ip
}

output "instance_arn" {
  description = "ARN of the Linux server instance"
  value       = aws_instance.linux_server.arn
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group for Linux server logs"
  value       = aws_cloudwatch_log_group.linux_logs.name
}

output "iam_role_name" {
  description = "Name of the IAM role for the Linux server"
  value       = aws_iam_role.linux_role.name
}

output "iam_instance_profile_name" {
  description = "Name of the IAM instance profile for the Linux server"
  value       = aws_iam_instance_profile.linux_profile.name
} 
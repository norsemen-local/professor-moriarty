output "instance_id" {
  description = "ID of the Windows server instance"
  value       = aws_instance.windows_server.id
}

output "private_ip" {
  description = "Private IP address of the Windows server"
  value       = aws_instance.windows_server.private_ip
}

output "public_ip" {
  description = "Public IP address of the Windows server"
  value       = aws_instance.windows_server.public_ip
}

output "instance_arn" {
  description = "ARN of the Windows server instance"
  value       = aws_instance.windows_server.arn
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group for Windows server logs"
  value       = aws_cloudwatch_log_group.windows_logs.name
}

output "iam_role_name" {
  description = "Name of the IAM role for the Windows server"
  value       = aws_iam_role.windows_role.name
}

output "iam_instance_profile_name" {
  description = "Name of the IAM instance profile for the Windows server"
  value       = aws_iam_instance_profile.windows_profile.name
} 
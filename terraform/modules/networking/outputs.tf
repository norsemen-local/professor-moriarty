output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "subnet_ids" {
  description = "Map of zone names to subnet IDs"
  value = {
    for zone, subnet in aws_subnet.private : zone => subnet.id
  }
}

output "subnet_cidr_blocks" {
  description = "Map of zone names to subnet CIDR blocks"
  value = {
    for zone, subnet in aws_subnet.private : zone => subnet.cidr_block
  }
}

output "security_groups" {
  description = "Map of zone names to security group IDs"
  value = {
    critical_infrastructure = aws_security_group.critical_infrastructure.id
    infrastructure         = aws_security_group.infrastructure.id
    users                 = aws_security_group.users.id
    dirty                 = aws_security_group.dirty.id
  }
}

output "route_table_ids" {
  description = "Map of zone names to route table IDs"
  value = {
    for zone, route_table in aws_route_table.private : zone => route_table.id
  }
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = var.enable_nat_gateway ? aws_nat_gateway.main[0].id : null
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = var.enable_nat_gateway ? aws_subnet.public[0].id : null
} 
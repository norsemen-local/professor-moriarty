variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name for resource tagging"
  type        = string
  default     = "academic"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "172.21.0.0/16"
}

# Instance Types
variable "ad_instance_type" {
  description = "Instance type for Active Directory servers"
  type        = string
  default     = "t3.medium"
}

variable "infrastructure_instance_type" {
  description = "Instance type for infrastructure servers"
  type        = string
  default     = "t3.medium"
}

variable "client_instance_type" {
  description = "Instance type for client machines"
  type        = string
  default     = "t3.small"
}

variable "firewall_instance_type" {
  description = "Instance type for Palo Alto Networks firewall"
  type        = string
  default     = "t3.large"
}

# Windows Server Configuration
variable "windows_server_ami" {
  description = "AMI ID for Windows Server 2022"
  type        = string
  default     = "ami-0c02fb55956c7d316" # Windows Server 2022 Base
}

variable "windows_client_ami" {
  description = "AMI ID for Windows 11"
  type        = string
  default     = "ami-0c02fb55956c7d316" # Windows 11 Base
}

# Linux Configuration
variable "debian_ami" {
  description = "AMI ID for Debian 12"
  type        = string
  default     = "ami-0c02fb55956c7d316" # Debian 12 Base
}

# Security Configuration
variable "enable_audit_logging" {
  description = "Enable comprehensive audit logging"
  type        = bool
  default     = true
}

variable "enable_mfa" {
  description = "Enable Multi-Factor Authentication"
  type        = bool
  default     = true
}

variable "enable_network_isolation" {
  description = "Enable network isolation between zones"
  type        = bool
  default     = true
}

# Palo Alto Networks Configuration
variable "palo_alto_license_type" {
  description = "Palo Alto Networks license type"
  type        = string
  default     = "byol"
}

variable "palo_alto_admin_password" {
  description = "Admin password for Palo Alto Networks firewall"
  type        = string
  sensitive   = true
  default     = "ChangeMe123!"
}

# Active Directory Configuration
variable "ad_domain_name" {
  description = "Active Directory domain name"
  type        = string
  default     = "academic.local"
}

variable "ad_admin_password" {
  description = "Active Directory administrator password"
  type        = string
  sensitive   = true
  default     = "ChangeMe123!"
}

# Network Security
variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "enable_vpc_flow_logs" {
  description = "Enable VPC Flow Logs for network monitoring"
  type        = bool
  default     = true
}

# Monitoring and Logging
variable "enable_cloudwatch_logs" {
  description = "Enable CloudWatch logging"
  type        = bool
  default     = true
}

variable "enable_cloudwatch_metrics" {
  description = "Enable CloudWatch metrics"
  type        = bool
  default     = true
}

# Backup and Recovery
variable "enable_backup" {
  description = "Enable automated backups"
  type        = bool
  default     = true
}

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 30
}

# Tags
variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Project     = "Academic-IaC"
    Environment = "Academic"
    Owner       = "Academic-Project"
    Purpose     = "Educational"
    Compliance  = "NIST-800-53"
    Framework   = "Zero-Trust"
  }
} 
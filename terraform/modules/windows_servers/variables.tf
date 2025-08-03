variable "server_name" {
  description = "Name of the Windows server"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the Windows server"
  type        = string
  default     = "t3.medium"
}

variable "subnet_id" {
  description = "Subnet ID where the server will be deployed"
  type        = string
}

variable "security_groups" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "key_name" {
  description = "SSH key name for server access"
  type        = string
}

variable "windows_ami" {
  description = "AMI ID for Windows Server"
  type        = string
  default     = "ami-0c02fb55956c7d316" # Windows Server 2022
}

variable "domain_name" {
  description = "Active Directory domain name"
  type        = string
  default     = "academic.local"
}

variable "admin_password" {
  description = "Administrator password for Windows server"
  type        = string
  sensitive   = true
  default     = "ChangeMe123!"
}

variable "environment" {
  description = "Environment name for resource tagging"
  type        = string
}

variable "server_role" {
  description = "Role of the Windows server"
  type        = string
  default     = "windows-server"
}

variable "zone" {
  description = "Network zone where the server is deployed"
  type        = string
  default     = "infrastructure"
}

variable "hardening_config" {
  description = "Security hardening configuration"
  type        = map(any)
  default = {
    enable_audit_logging = true
    enforce_password_policy = true
    enable_mfa = true
    restrict_admin_access = true
    enable_privileged_access_management = true
    enable_network_isolation = true
  }
}

variable "enable_cloudwatch_agent" {
  description = "Enable CloudWatch agent for monitoring"
  type        = bool
  default     = true
}

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
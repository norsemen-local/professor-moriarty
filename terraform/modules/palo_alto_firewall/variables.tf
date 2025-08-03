variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "Map of zone names to subnet IDs"
  type        = map(string)
}

variable "environment" {
  description = "Environment name for resource tagging"
  type        = string
}

variable "firewall_instance_type" {
  description = "Instance type for Palo Alto Networks firewall"
  type        = string
  default     = "t3.large"
}

variable "key_name" {
  description = "SSH key name for firewall access"
  type        = string
}

variable "palo_alto_ami" {
  description = "AMI ID for Palo Alto Networks VM-Series"
  type        = string
  default     = "ami-0c02fb55956c7d316" # Palo Alto Networks VM-Series
}

variable "admin_password" {
  description = "Admin password for Palo Alto Networks firewall"
  type        = string
  sensitive   = true
  default     = "ChangeMe123!"
}

variable "domain_name" {
  description = "Domain name for the firewall"
  type        = string
  default     = "academic.local"
}

variable "timezone" {
  description = "Timezone for the firewall"
  type        = string
  default     = "UTC"
}

variable "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  type        = string
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
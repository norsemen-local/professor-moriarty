variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "environment" {
  description = "Environment name for resource tagging"
  type        = string
}

variable "zones" {
  description = "Map of zone names to CIDR blocks"
  type        = map(string)
}

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
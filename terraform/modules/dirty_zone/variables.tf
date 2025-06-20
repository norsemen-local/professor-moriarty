# Variables for the Dirty Zone module.
# These define the characteristics of the shared Dirty Zone.

variable "dirty_zone_cidr" {
  description = "CIDR block for the Dirty Zone"
  type        = string
  default     = "192.168.0.0/16"
}

variable "dirty_zone_name" {
  description = "Name for the Dirty Zone"
  type        = string
  default     = "shared-dirty-zone"
}

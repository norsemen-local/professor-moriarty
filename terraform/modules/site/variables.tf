# Variables for the Site module.
# These variables allow customization of each site instance (e.g., Site A, Site B).

variable "site_identifier_octet" {
  description = "The second octet value that identifies the site (e.g., 21 for 172.21.x.x, 22 for 172.22.x.x)."
  type        = number
  # No default, this must be provided for each site instance
}

variable "site_name_prefix" {
  description = "A name prefix for the site (e.g., site-a, site-b)."
  type        = string
  default     = "site"
}

variable "first_octet" {
  description = "The first octet for the site networks (e.g., 172)."
  type        = number
  default     = 172
}

variable "zone_definitions" {
  description = "A map defining the zones to be created within the site."
  type = map(object({
    name_suffix = string
    third_octet = number
    cidr_suffix = string
  }))
  default = {
    "public" = {
      name_suffix = "public-zone"
      third_octet = 55
      cidr_suffix = "/24"
    },
    "users" = {
      name_suffix = "users-zone"
      third_octet = 45
      cidr_suffix = "/24"
    },
    "infrastructure" = {
      name_suffix = "infra-zone"
      third_octet = 25
      cidr_suffix = "/24"
    },
    "servers" = {
      name_suffix = "servers-zone"
      third_octet = 35
      cidr_suffix = "/24"
    },
    "remote_office" = {
      name_suffix = "remote-office-zone"
      third_octet = 15
      cidr_suffix = "/24"
    }
  }
}

# Root variable definitions for the Terraform project.
# These variables can be used to customize deployments.

variable "project_name" {
  description = "The name of the overall project."
  type        = string
  default     = "AcademicIaCProject"
}

variable "environment" {
  description = "The deployment environment (e.g., dev, test, prod, academic)."
  type        = string
  default     = "academic"
}

variable "global_first_octet" {
  description = "A global first octet that could be used to override the default in site modules if needed."
  type        = number
  default     = 172
  validation {
    condition     = var.global_first_octet >= 0 && var.global_first_octet <= 255
    error_message = "The first octet must be between 0 and 255."
  }
}

# Example of a more complex variable if we were to create sites dynamically from the root:
# variable "sites_to_create" {
#   description = "A list of site configurations to create."
#   type = list(object({
#     identifier_octet = number
#     name_prefix      = string
#     # other site-specific overrides
#   }))
#   default = [
#     { identifier_octet = 21, name_prefix = "site-a" },
#     { identifier_octet = 22, name_prefix = "site-b" },
#     # Add more sites here
#   ]
# }

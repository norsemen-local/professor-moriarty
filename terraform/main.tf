# Root main configuration for the Terraform project.
# This file defines the infrastructure resources and instantiates modules.

terraform {
  required_version = ">= 1.0" # Specifies the minimum Terraform version required.
}

# Provider configuration would go here if we were using a specific cloud provider.
# For this project, modules primarily use 'null_resource' for provider-agnostic demonstration.

# --- Shared Dirty Zone ---
# Instantiates the module responsible for creating the single, shared Dirty Zone.
# This zone is intended to be a common untrusted network segment.
module "shared_dirty_zone" {
  source = "./modules/dirty_zone"
  # Default variables from the module are used unless overridden here.
  # Example: dirty_zone_name = "custom-dirty-zone-name"
}

# --- Site A ---
# Instantiates a standard site configuration for 'Site A'.
# The 'site_identifier_octet' (21) is used by the module to calculate network ranges
# specific to this site (e.g., 172.21.x.x).
module "site_a" {
  source                = "./modules/site"
  site_identifier_octet = 21
  site_name_prefix      = "site-a"
  # 'first_octet' defaults to 172 within the module unless specified otherwise.
}

# --- Site B ---
# Instantiates a standard site configuration for 'Site B'.
# Demonstrates creating another distinct site by changing the 'site_identifier_octet' (22)
# and 'site_name_prefix'.
module "site_b" {
  source                = "./modules/site"
  site_identifier_octet = 22
  site_name_prefix      = "site-b"
  # You could also override other variables from the site module here, e.g.:
  # first_octet = 10
  # zone_definitions = { ... custom zone definitions for site_b ... }
}

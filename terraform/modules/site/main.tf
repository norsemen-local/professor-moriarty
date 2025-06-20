# Main configuration for the Site module.
# This module creates a standard set of network zones for a given site.

# The 'null_resource' with 'for_each' is used as a provider-agnostic placeholder
# to represent the creation of multiple network zones within the site.
# In a real-world scenario, this would be replaced with actual network resource
# definitions (e.g., 'aws_subnet', 'azurerm_subnet') likely within a VPC defined
# at the site level or passed as a variable.
resource "null_resource" "site_zone_placeholders" {
  for_each = var.zone_definitions # Iterates over the map of zone definitions.

  # The 'triggers' map simulates properties of the network zones.
  # It ensures that if any of these calculated values change, Terraform
  # would recognize a change in this placeholder resource.
  triggers = {
    zone_name    = "${var.site_name_prefix}-${var.site_identifier_octet}-${each.value.name_suffix}"
    cidr_block   = "${var.first_octet}.${var.site_identifier_octet}.${each.value.third_octet}.0${each.value.cidr_suffix}"
    # In a real scenario, you might add tags like:
    # site_name = var.site_name_prefix
    # site_octet = var.site_identifier_octet
  }
}

# 'locals' are used to structure the output data for the site zones.
# This creates a map of zone details, including simulated IDs.
locals {
  site_zones_details = {
    for zone_key, zone_config in var.zone_definitions :
    zone_key => {
      name       = "${var.site_name_prefix}-${var.site_identifier_octet}-${zone_config.name_suffix}"
      cidr       = "${var.first_octet}.${var.site_identifier_octet}.${zone_config.third_octet}.0${zone_config.cidr_suffix}"
      # Simulated ID using a hash of the CIDR block for some uniqueness.
      id         = "zone-${var.site_name_prefix}-${var.site_identifier_octet}-${zone_config.name_suffix}-${substr(md5("${var.first_octet}.${var.site_identifier_octet}.${zone_config.third_octet}.0${zone_config.cidr_suffix}"),0,4)}"
    }
  }
}

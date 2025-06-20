# Main configuration for the Dirty Zone module.
# This module defines the shared 'Dirty Zone' network.

# The 'null_resource' is used here as a provider-agnostic placeholder.
# In a real-world scenario with a specific cloud provider (AWS, Azure, GCP),
# this would be replaced with actual network resources like 'aws_vpc',
# 'azurerm_virtual_network', or 'google_compute_network'.
resource "null_resource" "dirty_network_placeholder" {
  # The 'triggers' map ensures this resource is re-evaluated if these values change.
  # It simulates properties that a real network resource would have.
  triggers = {
    cidr_block = var.dirty_zone_cidr
    name       = var.dirty_zone_name
  }
}

# 'locals' are used here to generate a simulated, deterministic ID for the placeholder resource.
# A real resource would provide its own unique ID (e.g., aws_vpc.main.id).
locals {
  simulated_dirty_zone_id = "dz-${var.dirty_zone_name}-${substr(md5(var.dirty_zone_cidr), 0, 8)}"
}

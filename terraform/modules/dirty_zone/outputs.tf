# Outputs for the Dirty Zone module.
# These expose key information about the Dirty Zone created by this module.

output "dirty_zone_id" {
  description = "The ID of the created Dirty Zone."
  # In a real scenario, this would reference the actual resource ID
  value       = local.simulated_dirty_zone_id
}

output "dirty_zone_cidr" {
  description = "The CIDR block of the Dirty Zone."
  value       = var.dirty_zone_cidr
}

output "dirty_zone_name" {
  description = "The name of the Dirty Zone."
  value       = var.dirty_zone_name
}

# Root output definitions for the Terraform project.
# These outputs expose important information about the created infrastructure.

output "shared_dirty_zone_details" {
  description = "Details of the shared Dirty Zone."
  value       = module.shared_dirty_zone
  # Sensitive can be set to true if output contains sensitive data
  # sensitive = true
}

output "site_a_details" {
  description = "Details of Site A and its zones."
  value       = module.site_a
}

output "site_b_details" {
  description = "Details of Site B and its zones."
  value       = module.site_b
}

# Example of a more structured output combining information from multiple sites
# (Requires sites to be created in a way that can be iterated, e.g. using for_each on module instantiation)
# output "all_sites_summary" {
#   description = "A summary of all created sites and their primary details."
#   value = {
#     for site_key, site_module in module.sites_group : # Assuming module.sites_group is a map of site modules
#     site_key => {
#       name = site_module.site_name
#       zones = length(site_module.site_zones)
#       # Add other summary details here
#     }
#   }
# }

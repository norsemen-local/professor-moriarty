# Outputs for the Site module.
# These outputs provide information about the site and its zones created by this module.

output "site_name" {
  description = "The full name of the site."
  value       = "${var.site_name_prefix}-${var.site_identifier_octet}"
}

output "site_zones" {
  description = "Details of all zones created for this site."
  value       = local.site_zones_details
  # In a real scenario, you might output actual resource IDs from null_resource.site_zone_placeholders
  # but null_resource itself does not have an easily accessible ID per for_each iteration without more complex constructs.
  # For now, local.site_zones_details provides a good structured output.
}

output "site_identifier_octet_used" {
  description = "The site identifier octet used for this site instance."
  value       = var.site_identifier_octet
}

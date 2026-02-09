locals {
  naming_prefixes = {
    sandbox = "tf_sandbox"
    prod    = "tf_prod"
  }
}

output "common_tags" {
  description = "Common tags to apply to all resources test"
  value = {
    managed_by  = "terraform"
    environment = var.environment
  }
}

output "naming_prefix" {
  description = "Environment-specific naming prefix for resources"
  value       = local.naming_prefixes[var.environment]
}

output "naming_prefixes" {
  description = "Map of all available naming prefixes by environment"
  value       = local.naming_prefixes
}

output "module_id" {
  description = "Generated module ID"
  value       = random_id.module_id.hex
}

output "module_full_name" {
  description = "Full module name with suffix"
  value       = "${var.module_name}-${random_string.module_suffix.result}"
}

output "module_version" {
  description = "Module version"
  value       = var.module_version
}

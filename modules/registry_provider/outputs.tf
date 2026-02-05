output "provider_id" {
  description = "Generated provider ID"
  value       = random_uuid.provider_id.result
}

output "provider_full_name" {
  description = "Full provider name"
  value       = "${var.provider_namespace}/${var.provider_name}"
}

output "provider_alias" {
  description = "Provider alias"
  value       = random_pet.provider_alias.id
}

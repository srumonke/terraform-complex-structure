output "org_id" {
  description = "Organisation ID"
  value       = random_uuid.org_id.result
}

output "org_name" {
  description = "Organisation name"
  value       = var.org_name
}

output "org_number" {
  description = "Organisation number"
  value       = random_integer.org_number.result
}

output "org_full_name" {
  description = "Full organisation identifier"
  value       = "${var.org_name}-${random_integer.org_number.result}"
}

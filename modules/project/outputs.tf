output "project_id" {
  description = "Project ID"
  value       = random_uuid.project_id.result
}

output "project_name" {
  description = "Project name"
  value       = var.project_name
}

output "project_code" {
  description = "Project code"
  value       = random_string.project_code.result
}

output "project_full_name" {
  description = "Full project identifier"
  value       = "${var.project_name}-${random_string.project_code.result}"
}

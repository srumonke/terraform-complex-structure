resource "random_uuid" "project_id" {
  keepers = {
    project_name = var.project_name
    org_id       = var.org_id
  }
}

resource "random_string" "project_code" {
  length  = 8
  special = false
  upper   = true
  numeric = true
  lower   = false
}

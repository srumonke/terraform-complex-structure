terraform {
  required_providers {
    harness = {
      source = "harness/harness"
    }
  }
}

# Step 1: Fetch the manifest that lists all workspace files
data "http" "manifest" {
  url = "${var.workspace_repo_raw_url}/${var.workspace_repo_branch}/workspaces/manifest.yaml"
}

locals {
  manifest_data  = yamldecode(data.http.manifest.response_body)
  workspace_files = local.manifest_data.files
}

# Step 2: Fetch each workspace file listed in the manifest
data "http" "workspace_files" {
  for_each = toset(local.workspace_files)
  url      = "${var.workspace_repo_raw_url}/${var.workspace_repo_branch}/workspaces/${each.value}"
}

# Step 3: Decode each file and merge all workspace maps
locals {
  all_workspaces = merge([
    for file_key, file_data in data.http.workspace_files :
    yamldecode(file_data.response_body).workspaces
  ]...)
  workspaces = local.all_workspaces
}

resource "harness_platform_workspace" "this" {
  for_each = local.workspaces

  name                    = each.value.name
  identifier              = each.value.identifier
  org_id                  = var.org_id
  project_id              = var.project_id
  provisioner_type        = each.value.provisioner_type
  provisioner_version     = each.value.provisioner_version
  repository              = each.value.repository
  repository_branch       = each.value.repository_branch
  repository_path         = each.value.repository_path
  repository_connector    = var.github_connector_id
  provider_connector      = var.github_connector_id
  cost_estimation_enabled = each.value.cost_estimation_enabled

  dynamic "terraform_variable" {
    for_each = each.value.terraform_variables
    content {
      key        = terraform_variable.key
      value      = terraform_variable.value.value
      value_type = terraform_variable.value.value_type
    }
  }
}

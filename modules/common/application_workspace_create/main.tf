locals {
  workspace_data = yamldecode(file(var.workspace_yaml_path))
  workspaces     = local.workspace_data.workspaces
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

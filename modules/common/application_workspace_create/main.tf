terraform {
  required_providers {
    harness = {
      source = "harness/harness"
    }
  }
}

# Load the application repos registry
locals {
  app_repos = yamldecode(file("${path.module}/application_repos.yaml")).repos
}

# Step 1: Fetch the manifest from each registered repo
data "http" "manifests" {
  for_each = local.app_repos
  url      = "${each.value.raw_url}/${each.value.branch}/workspaces/manifest.yaml"
}

# Step 2: Build a flat map of all workspace files across all repos
locals {
  workspace_file_map = merge([
    for repo_key, repo in local.app_repos : {
      for filename in yamldecode(data.http.manifests[repo_key].response_body).files :
      "${repo_key}/${filename}" => {
        url                 = "${repo.raw_url}/${repo.branch}/workspaces/${filename}"
        repo_key            = repo_key
        org_id              = repo.org_id
        project_id          = repo.project_id
        github_connector_id = repo.github_connector_id
      }
    }
  ]...)
}

# Step 3: Fetch all workspace files across all repos
data "http" "workspace_files" {
  for_each = local.workspace_file_map
  url      = each.value.url
}

# Step 4: Decode all files and merge workspaces, attaching repo metadata
locals {
  all_workspaces = merge([
    for file_key, file_meta in local.workspace_file_map : {
      for ws_key, ws in yamldecode(data.http.workspace_files[file_key].response_body).workspaces :
      "${file_meta.repo_key}/${ws_key}" => merge(ws, {
        org_id              = file_meta.org_id
        project_id          = file_meta.project_id
        github_connector_id = file_meta.github_connector_id
      })
    }
  ]...)
}

resource "harness_platform_workspace" "this" {
  for_each = local.all_workspaces

  name                    = each.value.name
  identifier              = each.value.identifier
  org_id                  = each.value.org_id
  project_id              = each.value.project_id
  provisioner_type        = each.value.provisioner_type
  provisioner_version     = each.value.provisioner_version
  repository              = each.value.repository
  repository_branch       = each.value.repository_branch
  repository_path         = each.value.repository_path
  repository_connector    = each.value.github_connector_id
  provider_connector      = each.value.github_connector_id
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

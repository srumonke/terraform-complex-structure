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

# Step 1: List files in the workspaces/ folder via GitHub API
data "http" "workspace_dirs" {
  for_each = local.app_repos
  url      = "https://api.github.com/repos/${each.value.repo}/contents/workspaces?ref=${each.value.branch}"

  request_headers = {
    Accept = "application/vnd.github.v3+json"
  }
}

# Step 2: Build a flat map of all workspace YAML files across all repos
locals {
  workspace_file_map = merge([
    for repo_key, repo in local.app_repos : {
      for file_entry in [
        for entry in jsondecode(data.http.workspace_dirs[repo_key].response_body) :
        entry if endswith(entry.name, ".yaml") || endswith(entry.name, ".yml")
      ] :
      "${repo_key}/${file_entry.name}" => {
        url                 = file_entry.download_url
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

# Trigger for the terraform repo itself — fires when application_repos.yaml changes
resource "harness_platform_trigger" "terraform_repo_push" {
  identifier = "terraform_repo_push_trigger"
  name       = "terraform-repo-push-trigger"
  org_id     = "TwilioCentraOrg"
  project_id = "Twilioinfra"
  target_id  = "iacm_workspace_provision_iacm"
  yaml       = <<-EOT
    trigger:
      name: terraform-repo-push-trigger
      identifier: terraform_repo_push_trigger
      enabled: true
      orgIdentifier: TwilioCentraOrg
      projectIdentifier: Twilioinfra
      pipelineIdentifier: iacm_workspace_provision_iacm
      source:
        type: Webhook
        spec:
          type: Github
          spec:
            type: Push
            spec:
              connectorRef: twilio_connector
              autoAbortPreviousExecutions: true
              payloadConditions:
                - key: targetBranch
                  operator: Equals
                  value: main
              headerConditions: []
              repoName: terraform-complex-structure
              actions: []
  EOT
}

# Auto-register a webhook trigger for each application repo
resource "harness_platform_trigger" "workspace_push" {
  for_each   = local.app_repos
  identifier = "${each.key}_push_trigger"
  name       = "${each.key}-push-trigger"
  org_id     = "TwilioCentraOrg"
  project_id = "Twilioinfra"
  target_id  = "iacm_workspace_provision_iacm"
  yaml       = <<-EOT
    trigger:
      name: ${each.key}-push-trigger
      identifier: ${each.key}_push_trigger
      enabled: true
      orgIdentifier: TwilioCentraOrg
      projectIdentifier: Twilioinfra
      pipelineIdentifier: iacm_workspace_provision_iacm
      source:
        type: Webhook
        spec:
          type: Github
          spec:
            type: Push
            spec:
              connectorRef: ${each.value.github_connector_id}
              autoAbortPreviousExecutions: true
              payloadConditions:
                - key: targetBranch
                  operator: Equals
                  value: ${each.value.branch}
              headerConditions: []
              repoName: ${split("/", each.value.repo)[1]}
              actions: []
  EOT
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

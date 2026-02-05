# Controller for org-01 workspace
# Uses the org-01 workspace directory directly as a module
module "org_01_workspace" {
  source = "../organisations/org-01"
}

output "org_01_workspace" {
  description = "Organisation 01 workspace with org and projects"
  value = {
    org     = module.org_01_workspace.org_01_info
    proj_11 = module.org_01_workspace.proj_11_info
    proj_12 = module.org_01_workspace.proj_12_info
  }
}

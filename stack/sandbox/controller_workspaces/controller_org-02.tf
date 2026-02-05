# Controller for org-02 workspace
# Uses the org-02 workspace directory directly as a module
module "org_02_workspace" {
  source = "../organisations/org-02"
}

output "org_02_workspace" {
  description = "Organisation 02 workspace with org and projects"
  value = {
    org      = module.org_02_workspace.org_02_info
    proj_21  = module.org_02_workspace.proj_21_info
    proj_22  = module.org_02_workspace.proj_22_info
  }
}

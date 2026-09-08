# Sources a module through the git submodule mounted at vendor/shared.
# vendor/shared is a pinned checkout of this same repository, so
# vendor/shared/modules/project is the same module as ../../../modules/project
# but reached through a gitlink instead of a plain directory.
#
# This folder exists to test the interaction between the IACM workspace
# "Include submodules" checkbox and "Sparse checkout" folder paths.

module "submodule_project" {
  source = "../../../vendor/shared/modules/project"

  project_name = "submodule-demo-app"
  org_id       = "org-01"
  common_tags = {
    demo   = "submodule"
    source = "vendor/shared"
  }
}

output "submodule_project_code" {
  description = "Proves the module behind the submodule actually evaluated."
  value       = module.submodule_project.project_code
}

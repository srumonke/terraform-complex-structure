# Controller for registry_modules workspace
# Uses the registry_modules workspace directory directly as a module
module "registry_modules_workspace" {
  source = "../registry_modules"
}

output "registry_modules_workspace" {
  description = "Registry modules workspace controller"
  value = {
    vpc_module        = module.registry_modules_workspace.vpc_module_info
    networking_module = module.registry_modules_workspace.networking_module_info
    common            = module.registry_modules_workspace.common_info
  }
}

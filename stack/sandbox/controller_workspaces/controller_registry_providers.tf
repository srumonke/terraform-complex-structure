# Controller for registry_provider workspace
# Uses the registry_provider workspace directory directly as a module
module "registry_provider_workspace" {
  source = "../registry_provider"
}

output "registry_provider_workspace" {
  description = "Registry provider workspace controller"
  value = {
    aws_provider     = module.registry_provider_workspace.aws_provider_info
    azurerm_provider = module.registry_provider_workspace.azurerm_provider_info
    common           = module.registry_provider_workspace.common_info
  }
}

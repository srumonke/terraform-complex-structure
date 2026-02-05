module "common" {
  source = "../../../modules/common"

  environment = "sandbox"
}

module "aws_provider" {
  source = "../../../modules/registry_provider"

  provider_name      = "aws"
  provider_namespace = "hashicorp"
}

module "azurerm_provider" {
  source = "../../../modules/registry_provider"

  provider_name      = "azurerm"
  provider_namespace = "hashicorp"
}

output "aws_provider_info" {
  description = "AWS provider information"
  value = {
    id        = module.aws_provider.provider_id
    full_name = module.aws_provider.provider_full_name
    alias     = module.aws_provider.provider_alias
  }
}

output "azurerm_provider_info" {
  description = "Azure provider information"
  value = {
    id        = module.azurerm_provider.provider_id
    full_name = module.azurerm_provider.provider_full_name
    alias     = module.azurerm_provider.provider_alias
  }
}

output "common_info" {
  description = "Common configuration"
  value = {
    naming_prefix = module.common.naming_prefix
    common_tags   = module.common.common_tags
  }
}

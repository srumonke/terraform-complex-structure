module "common" {
  source = "../../../modules/common"

  environment = "sandbox"
}

module "vpc_module" {
  source = "../../../modules/registry_modules"

  module_name    = "vpc"
  module_version = "2.0.0"
}

module "networking_module" {
  source = "../../../modules/registry_modules"

  module_name    = "networking"
  module_version = "1.5.0"
}

output "vpc_module_info" {
  description = "VPC module information"
  value = {
    id           = module.vpc_module.module_id
    full_name    = module.vpc_module.module_full_name
    version      = module.vpc_module.module_version
  }
}

output "networking_module_info" {
  description = "Networking module information"
  value = {
    id           = module.networking_module.module_id
    full_name    = module.networking_module.module_full_name
    version      = module.networking_module.module_version
  }
}

output "common_info" {
  description = "Common configuration"
  value = {
    naming_prefix = module.common.naming_prefix
    common_tags   = module.common.common_tags
  }
}

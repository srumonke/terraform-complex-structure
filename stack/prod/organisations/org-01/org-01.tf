module "common" {
  source = "../../../../modules/common"

  environment = "prod"
}

module "org_01" {
  source = "../../../../modules/organisation"

  org_name    = "org_01"
  org_email   = "org_01@example.com"
  common_tags = module.common.common_tags
}

output "org_01_info" {
  description = "Organisation 01 information"
  value = {
    id        = module.org_01.org_id
    name      = module.org_01.org_name
    number    = module.org_01.org_number
    full_name = module.org_01.org_full_name
  }
}

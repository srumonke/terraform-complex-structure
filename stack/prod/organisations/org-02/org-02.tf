module "common" {
  source = "../../../../modules/common"

  environment = "prod"
}

module "org_02" {
  source = "../../../../modules/organisation"

  org_name    = "org_02"
  org_email   = "org_02@example.com"
  common_tags = module.common.common_tags
}

output "org_02_info" {
  description = "Organisation 02 information"
  value = {
    id        = module.org_02.org_id
    name      = module.org_02.org_name
    number    = module.org_02.org_number
    full_name = module.org_02.org_full_name
  }
}

module "common" {
  source = "../../../../modules/common"

  environment = "sandbox"
}

module "org_03" {
  source = "../../../../modules/organisation"

  org_name    = "org_03"
  org_email   = "org_03@example.com"
  common_tags = module.common.common_tags
}

output "org_03_info" {
  description = "Organisation 03 information"
  value = {
    id        = module.org_03.org_id
    name      = module.org_03.org_name
    number    = module.org_03.org_number
    full_name = module.org_03.org_full_name
  }
}

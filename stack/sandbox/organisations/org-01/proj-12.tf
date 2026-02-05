module "proj_12" {
  source = "../../../../modules/project"

  project_name        = "proj_12"
  org_id              = module.org_01.org_id
  project_description = "Project 12 for Organisation 01"
  common_tags         = module.common.common_tags
}

output "proj_12_info" {
  description = "Project 12 information"
  value = {
    id        = module.proj_12.project_id
    name      = module.proj_12.project_name
    code      = module.proj_12.project_code
    full_name = module.proj_12.project_full_name
  }
}

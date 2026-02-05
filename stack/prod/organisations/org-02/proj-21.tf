module "proj_21" {
  source = "../../../../modules/project"

  project_name        = "proj_21"
  org_id              = module.org_02.org_id
  project_description = "Project 21 for Organisation 02"
  common_tags         = module.common.common_tags
}

output "proj_21_info" {
  description = "Project 21 information"
  value = {
    id        = module.proj_21.project_id
    name      = module.proj_21.project_name
    code      = module.proj_21.project_code
    full_name = module.proj_21.project_full_name
  }
}

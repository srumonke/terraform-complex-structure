module "proj_11" {
  source = "../../../../modules/project"

  project_name        = "proj_11"
  org_id              = module.org_01.org_id
  project_description = "Project 11 for Organisation 01"
  common_tags         = module.common.common_tags
}

output "proj_11_info" {
  description = "Project 11 information"
  value = {
    id        = module.proj_11.project_id
    name      = module.proj_11.project_name
    code      = module.proj_11.project_code
    full_name = module.proj_11.project_full_name
  }
}

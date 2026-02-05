module "proj_22" {
  source = "../../../../modules/project"

  project_name        = "proj_22"
  org_id              = module.org_02.org_id
  project_description = "Project 22 for Organisation 02"
  common_tags         = module.common.common_tags
}

output "proj_22_info" {
  description = "Project 22 information"
  value = {
    id        = module.proj_22.project_id
    name      = module.proj_22.project_name
    code      = module.proj_22.project_code
    full_name = module.proj_22.project_full_name
  }
}

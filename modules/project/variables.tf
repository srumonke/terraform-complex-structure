variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "org_id" {
  description = "Parent organisation ID"
  type        = string
}

variable "project_description" {
  description = "Project description"
  type        = string
  default     = "Terraform managed project"
}

variable "common_tags" {
  description = "Common tags from common module"
  type        = map(string)
  default     = {}
}

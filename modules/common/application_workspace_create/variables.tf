variable "workspace_repo_raw_url" {
  description = "Raw GitHub URL for the application repo (e.g. https://raw.githubusercontent.com/srumonke/create_iacm_workspace)"
  type        = string
  default     = "https://raw.githubusercontent.com/srumonke/create_iacm_workspace"
}

variable "workspace_repo_branch" {
  description = "Branch to fetch workspace files from"
  type        = string
  default     = "main"
}

variable "org_id" {
  description = "Harness organization identifier"
  type        = string
  default     = "default"
}

variable "project_id" {
  description = "Harness project identifier"
  type        = string
  default     = "Twilio"
}

variable "github_connector_id" {
  description = "GitHub connector identifier for workspace repositories"
  type        = string
  default     = "twilio_connector"
}

variable "workspace_yaml_path" {
  description = "Path to the workspace.yaml file from the application repo"
  type        = string
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

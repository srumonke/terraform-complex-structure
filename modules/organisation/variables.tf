variable "org_name" {
  description = "Name of the organisation"
  type        = string
}

variable "org_email" {
  description = "Organisation email"
  type        = string
  default     = "admin@example.com"
}

variable "common_tags" {
  description = "Common tags from common module"
  type        = map(string)
  default     = {}
}

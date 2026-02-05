variable "provider_name" {
  description = "Name of the registry provider"
  type        = string
}

variable "provider_namespace" {
  description = "Namespace for the provider"
  type        = string
  default     = "hashicorp"
}

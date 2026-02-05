variable "environment" {
  description = "Environment name (sandbox, prod)"
  type        = string
  default     = "sandbox"

  validation {
    condition     = contains(["sandbox", "prod"], var.environment)
    error_message = "Environment must be either 'sandbox' or 'prod'."
  }
}

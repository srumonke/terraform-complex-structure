resource "random_id" "module_id" {
  byte_length = 8

  keepers = {
    module_name = var.module_name
  }
}

resource "random_string" "module_suffix" {
  length  = 6
  special = false
  upper   = false
}

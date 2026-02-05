resource "random_uuid" "provider_id" {
  keepers = {
    provider_name = var.provider_name
  }
}

resource "random_pet" "provider_alias" {
  length    = 2
  separator = "-"
}

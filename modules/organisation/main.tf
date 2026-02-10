resource "random_uuid" "org_id" {
  keepers = {
    org_name = var.org_name
  }
}

resource "random_integer" "org_number" {
  min = 1002
  max = 9999

  keepers = {
    org_name = var.org_name
  }
}

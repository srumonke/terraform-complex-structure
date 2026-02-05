terraform {
  backend "local" {
    path = "terraform.tfstate"
  }

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  required_version = ">= 1.0"
}

provider "random" {}

terraform {
  required_providers {
    vultr = {
      source  = "vultr/vultr"
      version = "2.31.2"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

terraform {
  required_version = ">= 1.6"

  required_providers {
    kong-gateway = {
      source  = "kong/kong-gateway"
      version = "~> 1.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

# Le provider parle à l'Admin API (control plane), exposée uniquement en local
provider "kong-gateway" {
  server_url = var.kong_admin_url
}

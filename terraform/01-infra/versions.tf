terraform {
  required_version = ">= 1.6"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

# Se connecte au démon Docker local (unix:///var/run/docker.sock)
provider "docker" {}

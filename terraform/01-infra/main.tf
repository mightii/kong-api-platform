locals {
  api_dir = "${path.module}/../../api"

  # Variables communes à tous les conteneurs Kong (migrations + gateway)
  kong_db_env = [
    "KONG_DATABASE=postgres",
    "KONG_PG_HOST=${docker_container.postgres.name}",
    "KONG_PG_USER=kong",
    "KONG_PG_PASSWORD=${var.pg_password}",
    "KONG_PG_DATABASE=kong",
  ]
}

# ---------------------------------------------------------------- Réseau
# Réseau dédié : les conteneurs se joignent par leur nom (DNS interne de Docker)
resource "docker_network" "kong" {
  name = "kong-platform-net"

  ipam_config {
    subnet = var.network_subnet
  }
}

resource "docker_volume" "pg_data" {
  name = "kong-platform-pg-data"
}

# ---------------------------------------------------------------- Images
resource "docker_image" "postgres" {
  name         = var.postgres_image
  keep_locally = true
}

resource "docker_image" "kong" {
  name         = var.kong_image
  keep_locally = true
}

# Image de l'API construite depuis api/ ; reconstruite si un fichier change
resource "docker_image" "api" {
  name = "kong-platform-api:local"

  build {
    context = local.api_dir
  }

  triggers = {
    source_hash = sha1(join("", [
      for f in fileset(local.api_dir, "*") : filesha1("${local.api_dir}/${f}")
    ]))
  }
}

# ---------------------------------------------------------------- PostgreSQL
resource "docker_container" "postgres" {
  name    = "kong-database"
  image   = docker_image.postgres.image_id
  restart = "unless-stopped"

  env = [
    "POSTGRES_DB=kong",
    "POSTGRES_USER=kong",
    "POSTGRES_PASSWORD=${var.pg_password}",
  ]

  networks_advanced {
    name = docker_network.kong.name
  }

  volumes {
    volume_name    = docker_volume.pg_data.name
    container_path = "/var/lib/postgresql/data"
  }

  healthcheck {
    test     = ["CMD", "pg_isready", "-U", "kong", "-d", "kong"]
    interval = "5s"
    timeout  = "5s"
    retries  = 10
  }

  # Terraform attend que Postgres soit "healthy" avant de continuer
  wait         = true
  wait_timeout = 60
}

# ---------------------------------------------------------------- Migrations
# Conteneur à usage unique : initialise le schéma, puis s'arrête.
# attach = true : Terraform attend la fin de l'exécution.
resource "docker_container" "kong_migrations" {
  name     = "kong-migrations"
  image    = docker_image.kong.image_id
  command  = ["kong", "migrations", "bootstrap"]
  env      = local.kong_db_env
  attach   = true
  logs     = true
  must_run = false

  networks_advanced {
    name = docker_network.kong.name
  }

  depends_on = [docker_container.postgres]
}

# ---------------------------------------------------------------- Kong Gateway
resource "docker_container" "kong" {
  name    = "kong-gateway"
  image   = docker_image.kong.image_id
  restart = "unless-stopped"

  env = concat(local.kong_db_env, [
    "KONG_PROXY_LISTEN=0.0.0.0:8000",
    "KONG_ADMIN_LISTEN=0.0.0.0:8001",
    "KONG_ADMIN_GUI_LISTEN=0.0.0.0:8002",
    "KONG_ADMIN_GUI_URL=http://localhost:8002",
    "KONG_PROXY_ACCESS_LOG=/dev/stdout",
    "KONG_ADMIN_ACCESS_LOG=/dev/stdout",
    "KONG_PROXY_ERROR_LOG=/dev/stderr",
    "KONG_ADMIN_ERROR_LOG=/dev/stderr",
  ])

  networks_advanced {
    name = docker_network.kong.name
  }

  # Data plane : ouvert
  ports {
    internal = 8000
    external = 8000
  }

  # Control plane : uniquement en local (accès via tunnel SSH)
  ports {
    internal = 8001
    external = 8001
    ip       = "127.0.0.1"
  }

  ports {
    internal = 8002
    external = 8002
    ip       = "127.0.0.1"
  }

  healthcheck {
    test     = ["CMD", "kong", "health"]
    interval = "10s"
    timeout  = "10s"
    retries  = 10
  }

  wait         = true
  wait_timeout = 120

  depends_on = [docker_container.kong_migrations]
}

# ---------------------------------------------------------------- API de démo
# Aucun port exposé sur la VM : seul Kong y accède, via le réseau Docker.
resource "docker_container" "api" {
  name    = "demo-api"
  image   = docker_image.api.image_id
  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.kong.name
  }
}

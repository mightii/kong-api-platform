locals {
  observability_dir = "${path.module}/../../observability"
}

resource "docker_image" "prometheus" {
  name         = var.prometheus_image
  keep_locally = true
}

resource "docker_image" "grafana" {
  name         = var.grafana_image
  keep_locally = true
}

# ---------------------------------------------------------------- Prometheus
# Collecte les métriques de Kong toutes les 5 secondes
resource "docker_container" "prometheus" {
  name    = "prometheus"
  image   = docker_image.prometheus.image_id
  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.kong.name
  }

  upload {
    content = file("${local.observability_dir}/prometheus.yml")
    file    = "/etc/prometheus/prometheus.yml"
  }

  ports {
    internal = 9090
    external = 9090
    ip       = "127.0.0.1"
  }

  depends_on = [docker_container.kong]
}

# ---------------------------------------------------------------- Grafana
# La source de données Prometheus est provisionnée automatiquement
resource "docker_container" "grafana" {
  name    = "grafana"
  image   = docker_image.grafana.image_id
  restart = "unless-stopped"

  env = [
    "GF_SECURITY_ADMIN_PASSWORD=${var.grafana_admin_password}",
  ]

  networks_advanced {
    name = docker_network.kong.name
  }

  upload {
    content = file("${local.observability_dir}/grafana-datasource.yml")
    file    = "/etc/grafana/provisioning/datasources/prometheus.yml"
  }

  ports {
    internal = 3000
    external = 3000
    ip       = "127.0.0.1"
  }

  depends_on = [docker_container.prometheus]
}

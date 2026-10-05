variable "kong_image" {
  description = "Image Kong Gateway (version LTS)"
  type        = string
  default     = "kong/kong-gateway:3.10"
}

variable "postgres_image" {
  description = "Image PostgreSQL"
  type        = string
  default     = "postgres:16-alpine"
}

variable "network_subnet" {
  description = "Sous-réseau du réseau Docker (plage privée RFC 1918)"
  type        = string
  default     = "172.30.0.0/24"
}

variable "pg_password" {
  description = "Mot de passe PostgreSQL de Kong"
  type        = string
  sensitive   = true
}

variable "prometheus_image" {
  description = "Image Prometheus"
  type        = string
  default     = "prom/prometheus:latest"
}

variable "grafana_image" {
  description = "Image Grafana"
  type        = string
  default     = "grafana/grafana-oss:latest"
}

variable "grafana_admin_password" {
  description = "Mot de passe admin de Grafana"
  type        = string
  sensitive   = true
}

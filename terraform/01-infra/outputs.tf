output "proxy_url" {
  description = "Data plane : point d'entrée des clients"
  value       = "http://localhost:8000"
}

output "admin_api_url" {
  description = "Control plane : Admin API (local uniquement)"
  value       = "http://localhost:8001"
}

output "kong_manager_url" {
  description = "Interface d'administration (via tunnel SSH)"
  value       = "http://localhost:8002"
}

output "api_upstream_url" {
  description = "URL de l'API vue depuis Kong (résolution DNS Docker)"
  value       = "http://${docker_container.api.name}:5000"
}

output "api_host" {
  description = "Nom DNS de l'API sur le réseau Docker"
  value       = docker_container.api.name
}

output "api_port" {
  description = "Port de l'API dans son conteneur"
  value       = 5000
}

output "grafana_url" {
  description = "Grafana (via tunnel SSH)"
  value       = "http://localhost:3000"
}

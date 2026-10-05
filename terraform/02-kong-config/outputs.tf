output "test_url" {
  description = "URL de test via le proxy Kong"
  value       = "http://localhost:8000/api/healthy"
}

output "api_keys" {
  description = "Clés API des partenaires (terraform output -json api_keys)"
  value       = { for k, v in random_password.api_key : k => v.result }
  sensitive   = true
}

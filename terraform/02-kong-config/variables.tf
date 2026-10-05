variable "kong_admin_url" {
  description = "URL de l'Admin API de Kong"
  type        = string
  default     = "http://localhost:8001"
}

variable "tiers" {
  description = "Niveaux d'abonnement : limite de requêtes par minute"
  type        = map(number)
  default = {
    gold = 100
    free = 5
  }
}

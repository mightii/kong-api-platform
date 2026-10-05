# ---------------------------------------------------------------- Lien avec la couche 01
# Lecture des sorties de l'infrastructure : la couche 02 ne connaît pas les détails
# de la couche 01, seulement son "contrat" (ses outputs).
data "terraform_remote_state" "infra" {
  backend = "local"

  config = {
    path = "${path.module}/../01-infra/terraform.tfstate"
  }
}

# ---------------------------------------------------------------- Acte 1 : exposer
resource "kong-gateway_service" "api" {
  name     = "demo-api"
  protocol = "http"
  host     = data.terraform_remote_state.infra.outputs.api_host
  port     = data.terraform_remote_state.infra.outputs.api_port
  tags     = ["managed-by-terraform"]
}

resource "kong-gateway_route" "api" {
  name       = "demo-api-route"
  paths      = ["/api"]
  protocols  = ["http", "https"]
  strip_path = true
  tags       = ["managed-by-terraform"]

  service = {
    id = kong-gateway_service.api.id
  }
}

# ---------------------------------------------------------------- Acte 2 : sécuriser
# Sans clé valide : 401. La clé n'est pas transmise à l'API (hide_credentials).
resource "kong-gateway_plugin_key_auth" "api" {
  enabled   = true
  protocols = ["http", "https"]
  tags      = ["managed-by-terraform"]

  config = {
    key_names        = ["apikey"]
    hide_credentials = true
  }

  service = {
    id = kong-gateway_service.api.id
  }
}

# Un consumer par niveau d'abonnement
resource "kong-gateway_consumer" "partner" {
  for_each = var.tiers

  username  = "partenaire-${each.key}"
  custom_id = "partenaire-${each.key}"
  tags      = ["managed-by-terraform", "tier-${each.key}"]
}

# Clés API générées par Terraform (elles vivent dans le state : voir docs/05)
resource "random_password" "api_key" {
  for_each = var.tiers

  length  = 32
  special = false
}

resource "kong-gateway_key_auth" "partner" {
  for_each = var.tiers

  key         = random_password.api_key[each.key].result
  consumer_id = kong-gateway_consumer.partner[each.key].id
}

# ---------------------------------------------------------------- Acte 3 : gouverner
# Rate limiting au niveau du consumer : chaque niveau a sa propre limite.
resource "kong-gateway_plugin_rate_limiting" "tier" {
  for_each = var.tiers

  enabled   = true
  protocols = ["http", "https"]
  tags      = ["managed-by-terraform"]

  config = {
    minute = each.value
    policy = "local"
  }

  consumer = {
    id = kong-gateway_consumer.partner[each.key].id
  }
}

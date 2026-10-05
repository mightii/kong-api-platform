# 05. Terraform : la configuration de Kong

**Date :** 5 octobre 2026

## Objectif

Décrire en Terraform toute la configuration de Kong : service, route, authentification,
consumers et quotas par niveau d'abonnement. Plus aucun `curl` manuel sur l'Admin API.

## Pourquoi

- La configuration de la gateway suit le même cycle que l'infrastructure : revue de code,
  `plan`, `apply`, historique dans git.
- Le provider officiel `kong/kong-gateway` cible les gateways auto-hébergées et parle à l'Admin API.

## Choix techniques

| Choix | Raison |
|---|---|
| Deux states (01-infra et 02-kong-config) | La couche 02 a besoin d'un Kong démarré. Rayon d'impact limité : modifier une route ne peut pas détruire la base |
| `terraform_remote_state` | La couche 02 lit les sorties de la couche 01 (nom et port de l'API) au lieu de les coder en dur |
| `key-auth` au niveau du service | Toute requête sans clé valide est rejetée (401) |
| `hide_credentials = true` | La clé API n'est pas transmise à l'API amont |
| Rate limiting au niveau du **consumer** | Un plugin par niveau d'abonnement (gold : 100/min, free : 5/min) |
| `for_each` sur une `map` de niveaux | Ajouter un niveau = ajouter une ligne dans `var.tiers` |
| Clés générées par `random_password` | Aucune clé écrite à la main dans le code |
| Tag `managed-by-terraform` | Repérer dans Kong Manager ce qui est géré par le code |

## Ce que j'ai fait

```bash
# La couche 01 expose deux nouvelles sorties
cd terraform/01-infra && terraform apply

cd ../02-kong-config
terraform init
terraform fmt -check && terraform validate
terraform plan
terraform apply
```

### Tests

```bash
curl -i localhost:8000/api/healthy                      # 401 : pas de clé

FREE=$(terraform output -json api_keys | jq -r .free)
GOLD=$(terraform output -json api_keys | jq -r .gold)

for i in $(seq 1 7); do curl -s -o /dev/null -w "%{http_code} " -H "apikey: $FREE" localhost:8000/api/healthy; done; echo
for i in $(seq 1 7); do curl -s -o /dev/null -w "%{http_code} " -H "apikey: $GOLD" localhost:8000/api/healthy; done; echo
```

## Résultat

<!-- TODO : sortie des tests (attendu : free = 200 x5 puis 429 ; gold = 200 x7) + capture Kong Manager -->

## Problèmes rencontrés et solutions

| Symptôme | Cause | Solution |
|---|---|---|
| | | |

## Ce que j'en retiens

- **Les clés API sont dans le state Terraform.** En production : state distant chiffré
  avec contrôle d'accès, ou clés émises par un gestionnaire de secrets (Vault) plutôt que par Terraform.
- Avec Terraform, chaque entité créée hors Terraform doit être importée dans le state.
  decK, l'outil de Kong, sait exporter et réinitialiser une configuration complète plus simplement.
  Critère de choix : les processus existants du client (voir `decisions.md`).
- Précédence des plugins Kong : un plugin configuré sur un consumer prend le pas sur
  un plugin du même type configuré globalement ou sur le service.

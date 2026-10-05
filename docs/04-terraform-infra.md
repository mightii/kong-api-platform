# 04. Terraform : l'infrastructure

**Date :** 5 octobre 2026

## Objectif

Remplacer le `docker-compose.yml` de la formation par une infrastructure décrite en Terraform :
réseau, base de données, migrations, Kong Gateway et API de démonstration.

## Pourquoi

- **Un seul workflow** pour l'infrastructure et, à l'étape 05, pour la configuration de Kong :
  `plan` pour prévisualiser, `apply` pour appliquer, revue de code sur le HCL.
- **Localement la cible est Docker** (provider `kreuzwerker/docker`). En entreprise, le même
  workflow viserait Kubernetes ou un cloud public : seul le provider changerait.

## Choix techniques

| Choix | Raison |
|---|---|
| `kong/kong-gateway` 3.10 | Image utilisée par les clients en production (mode gratuit sans licence), version LTS |
| Postgres plutôt que DB-less | En DB-less, l'Admin API est en lecture seule : Terraform ne pourrait rien créer à l'étape 05 |
| Migrations dans un conteneur à usage unique | `attach = true` : Terraform attend la fin de l'initialisation avant de démarrer Kong |
| `wait = true` + healthchecks | L'ordre de démarrage est garanti par l'état de santé, pas seulement par l'ordre de création |
| Réseau dédié, sous-réseau `172.30.0.0/24` | Plage privée RFC 1918. Le compose de la formation utilisait `172.1.1.0/24`, qui est une plage **publique** |
| API joignable par son nom (`demo-api:5000`) | DNS interne Docker : plus besoin de l'adresse de la passerelle (`172.1.1.1`) utilisée à l'étape 03 |
| API sans port exposé sur la VM | Seul Kong y accède : impossible de contourner la gateway |
| Admin API et Kong Manager sur `127.0.0.1` | Le control plane n'est pas exposé ; accès via tunnel SSH |
| Image de l'API en utilisateur non-root | Moindre privilège |
| Mot de passe en variable `sensitive` dans un `terraform.tfvars` ignoré par git | Pas de secret dans le dépôt |

## Ce que j'ai fait

```bash
cd terraform/01-infra
cp terraform.tfvars.example terraform.tfvars   # puis modification du mot de passe
terraform init
terraform fmt -check
terraform validate
terraform plan
terraform apply
```

## Résultat

<!-- TODO : sortie de terraform apply, docker ps, version de Kong, capture de Kong Manager -->

## Problèmes rencontrés et solutions

| Symptôme | Cause | Solution |
|---|---|---|
| | | |

## Ce que j'en retiens

- Le **state Terraform contient le mot de passe en clair** (dans les variables d'environnement
  des conteneurs). C'est pourquoi il n'est jamais versionné. En production : state distant
  chiffré (HCP Terraform) et secrets dynamiques fournis par Vault.
- `sensitive = true` masque la valeur dans l'affichage, pas dans le state.

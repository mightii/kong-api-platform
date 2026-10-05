# 06. Observabilité

**Date :** 6 octobre 2026

## Objectif

Rendre visible ce qui passe par la gateway : volume de requêtes par consumer, codes HTTP
(dont les `401` et les `429`), latence ajoutée par Kong et latence de l'API.

## Pourquoi

Une gateway est un point de passage obligé : c'est l'endroit idéal pour mesurer tout le
trafic API **sans instrumenter chaque service**.

## Architecture

```
Clients ──> Kong (8000) ──> demo-api
              │
              └─ Status API (8100) /metrics ──> Prometheus (scrape 5 s) ──> Grafana
```

## Choix techniques

| Choix | Raison |
|---|---|
| Plugin `prometheus` **global** | Toutes les routes sont mesurées, y compris les futures, sans configuration supplémentaire |
| `per_consumer: true` | Métriques détaillées par partenaire : on voit qui consomme quoi |
| Métriques exposées sur le **Status API** (8100), pas sur l'Admin API | Séparation des rôles : la supervision n'a pas besoin des droits d'administration |
| Port 8100 non publié sur la VM | Seul Prometheus le lit, via le réseau Docker |
| Source de données Grafana provisionnée | Grafana est prêt à l'emploi dès son démarrage |
| Prometheus et Grafana déployés par Terraform | Même cycle de vie que le reste de l'infrastructure |

## Ce que j'ai fait

```bash
# Infrastructure : Status API de Kong + Prometheus + Grafana
cd terraform/01-infra
terraform plan        # attendu : kong-gateway remplacé (nouvelle variable d'environnement)
terraform apply

# Configuration Kong : plugin Prometheus
cd ../..
set -a; source .env; set +a
deck gateway diff kong/kong.yaml
deck gateway sync kong/kong.yaml

# Trafic de démonstration
bash scripts/trafic.sh 120
```

Dans Grafana (http://localhost:3000) : Dashboards > New > Import > ID **7424**
(tableau de bord officiel Kong), source de données `Prometheus`.

## Résultat

<!-- TODO : captures Grafana (requêtes par consumer, 429 du niveau free, latences Kong vs upstream) -->

## Problèmes rencontrés et solutions

| Symptôme | Cause | Solution |
|---|---|---|
| | | |

## Ce que j'en retiens

- `kong_latency` (temps passé dans Kong) et `upstream_latency` (temps passé dans l'API) se
  distinguent : en cas de lenteur, on sait immédiatement de quel côté chercher.
- Les `429` du niveau free deviennent un signal métier : un partenaire qui les atteint
  souvent est un candidat à l'upsell vers le niveau gold.

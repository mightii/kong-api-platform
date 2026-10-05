# Kong API Platform : POC « as code »

> Plateforme API pour une entreprise française fictive, propulsée par Kong Gateway et déployée as code.

## Contexte

<!-- TODO : 3-4 lignes sur le problème client que ce POC résout -->

## Architecture

<!-- TODO : schéma (docs/images/architecture.png) + lien vers docs/architecture.md -->

## Ce que démontre ce POC

1. **Exposer** une API derrière Kong Gateway (service, route)
2. **Sécuriser** l'accès (key-auth, consumers)
3. **Gouverner** la consommation (rate limiting par niveau d'abonnement)
4. **Observer** le trafic (Prometheus, Grafana)
5. **Ouvrir à l'IA** : Kong comme AI Gateway (`ai-proxy`)

## Démarrage rapide

<!-- TODO : les 3 commandes pour tout lancer -->

## Journal de bord

| # | Étape |
|---|---|
| 00 | [Contexte et objectifs](docs/00-contexte-et-objectifs.md) |
| 01 | [Préparation de la VM](docs/01-preparation-vm.md) |
| 02 | [Environnement Python](docs/02-environnement-python.md) |
| 03 | [Premiers pas avec Kong](docs/03-premier-pas-kong.md) |
| 04 | [Terraform : infrastructure](docs/04-terraform-infra.md) |
| 05 | [Configuration de Kong : exposer, sécuriser, gouverner](docs/05-configuration-kong.md) |
| 06 | Observabilité *(à venir)* |
| 07 | AI Gateway *(à venir)* |

Voir aussi : [décisions d'architecture](docs/decisions.md) · [passage en production](docs/production.md)

## Crédits

L'API de démonstration (`api/`) est reprise du dépôt de formation
[raj713335/kong-gateway](https://github.com/raj713335/kong-gateway) (licence BSD-3-Clause).

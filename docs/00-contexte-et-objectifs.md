# 00. Contexte et objectifs

**Date :** 5 octobre 2026

## Contexte

Une entreprise française expose de plus en plus d'API, en interne et à des partenaires.
Chaque équipe gère aujourd'hui sa propre sécurité, ses propres quotas et ses propres logs.
Résultat : des pratiques hétérogènes, aucune vue d'ensemble, et des changements faits
à la main que personne ne trace.

Les équipes plateforme pilotent déjà leur infrastructure avec Terraform, avec revue de
code et pipeline d'approbation. Toute nouvelle brique doit s'insérer dans ce workflow.

## Objectifs du POC

- Centraliser les politiques transverses (sécurité, quotas, observabilité) dans une
  API Gateway, **sans modifier le code des services**.
- Déployer l'infrastructure **et** la configuration de Kong entièrement as code.
- Rendre la dérive de configuration visible et corrigeable.
- Documenter chaque étape et chaque choix technique.

## Périmètre

| Inclus | Hors périmètre (voir `production.md`) |
|---|---|
| Kong Gateway + Postgres, en conteneurs | Haute disponibilité, hybrid mode |
| Terraform (provider docker + provider kong-gateway) | Kubernetes, cloud public |
| key-auth, rate limiting, Prometheus/Grafana | SSO/OIDC, mTLS |

## Environnement de travail

- MacBook Apple Silicon + VirtualBox
- VM Ubuntu Server 26.04 LTS (arm64), 2 vCPU, 4 Go RAM, accès SSH

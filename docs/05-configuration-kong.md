# 05. Configuration de Kong : exposer, sécuriser, gouverner

**Date :** 5 octobre 2026

## Objectif

Configurer les trois premiers actes de la démo, de façon déclarative avec decK :

1. **Exposer** l'API derrière la gateway (service + route)
2. **Sécuriser** l'accès (key-auth + consumers)
3. **Gouverner** la consommation (rate limiting par niveau d'abonnement)

## Pourquoi decK

- C'est l'outil de Kong pour gérer la configuration as code : un fichier `kong.yaml`
  lisible, versionné, appliqué avec `diff` puis `sync`.
- Terraform reste utilisé pour l'**infrastructure** (étape 04). La **configuration** de la
  gateway est gérée avec l'outil natif de Kong. Voir `decisions.md` pour le compromis
  decK / Terraform.

## Choix techniques

| Choix | Raison |
|---|---|
| `select_tags: kong-api-platform` | decK ne gère que les entités portant ce tag : aucun risque de supprimer une configuration qui ne lui appartient pas |
| Service vers `demo-api:5000` | Résolution DNS du réseau Docker, l'API n'est exposée qu'à Kong |
| `key-auth` sur le service | Toute requête sans clé valide est rejetée (401) |
| `hide_credentials: true` | La clé n'est pas transmise à l'API amont |
| Rate limiting sur chaque **consumer** | Un contrat par niveau : gold 100/min, free 5/min |
| Clés injectées par variables d'environnement (`${{ env "DECK_..." }}`) | Aucun secret dans le dépôt ; `.env` est ignoré par git |

## Ce que j'ai fait

```bash
set -a; source .env; set +a          # charge les clés dans l'environnement
deck gateway ping
deck file validate kong/kong.yaml
deck gateway diff kong/kong.yaml     # prévisualiser
deck gateway sync kong/kong.yaml     # appliquer
```

### Tests

```bash
curl -i localhost:8000/api/healthy    # 401 : pas de clé

for i in $(seq 1 7); do curl -s -o /dev/null -w "%{http_code} " -H "apikey: $DECK_FREE_KEY" localhost:8000/api/healthy; done; echo
for i in $(seq 1 7); do curl -s -o /dev/null -w "%{http_code} " -H "apikey: $DECK_GOLD_KEY" localhost:8000/api/healthy; done; echo
```

## Résultat

<!-- TODO : sorties des tests (attendu : 401 ; free = 200 x5 puis 429 x2 ; gold = 200 x7) + capture Kong Manager -->

## Problèmes rencontrés et solutions

| Symptôme | Cause | Solution |
|---|---|---|
| | | |

## Ce que j'en retiens

- La même API, deux contrats de service différents, **sans modifier une ligne de code de l'API** :
  c'est la valeur d'une gateway.
- Précédence des plugins : un plugin configuré sur un consumer prend le pas sur le même
  plugin configuré globalement ou sur le service.
- `deck gateway diff` montre exactement ce qui va changer avant de l'appliquer.

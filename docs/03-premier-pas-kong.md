# 03. Premiers pas avec Kong

**Date :** 5 octobre 2026

## Objectif

Faire passer une première requête par Kong, de bout en bout, et appliquer un premier plugin.

## Pourquoi

Comprendre le modèle de base avant de l'automatiser :
**client → Kong (proxy) → service**.

## Ce que j'ai fait

### 1. Démarrage modulaire de la stack de formation

Le `docker-compose.yml` de la formation lance une quinzaine de services, dont plusieurs JVM
(Keycloak, Zipkin, Elasticsearch, Logstash). Avec 4 Go de RAM, je démarre uniquement le
nécessaire :

```bash
docker compose up -d kong-database
docker compose up kong-migrations     # initialise le schéma Postgres de Kong
docker compose up -d kong
curl -s localhost:8001 | jq '.version'
```

### 2. Accès aux interfaces depuis le Mac : tunnel SSH

L'Admin API (8001) et Kong Manager (8002) n'écoutent que sur `127.0.0.1` dans la VM
(bonne pratique). Pour y accéder depuis le navigateur du Mac :

```bash
ssh -p 2222 -L 8001:localhost:8001 -L 8002:localhost:8002 manu@127.0.0.1
```

### 3. Service et route

```bash
curl -s -X POST localhost:8001/services --data name=fastapi --data url=http://172.1.1.1:5000
curl -s -X POST localhost:8001/services/fastapi/routes --data name=fastapi-route --data 'paths[]=/api'
curl -i localhost:8000/api/docs
```

### 4. Premier plugin : rate limiting

```bash
curl -s -X POST localhost:8001/services/fastapi/plugins \
  --data name=rate-limiting --data config.minute=5 --data config.policy=local
```

## Résultat

```
HTTP/1.1 200 OK
X-Kong-Upstream-Latency: 9
X-Kong-Proxy-Latency: 2
Via: kong/3.7.1
```

Kong n'ajoute que 2 ms. Au-delà de 5 requêtes par minute : `429 Too Many Requests`,
sans aucune modification du code de l'API.

## Problèmes rencontrés et solutions

| Symptôme | Cause | Solution |
|---|---|---|
| Konga inutilisable | Projet abandonné, image amd64 uniquement (VM arm64), non conçu pour Kong 3.x | Kong Manager, inclus dans Kong 3.x |
| Kong ne joint pas l'API | Uvicorn écoutait sur `localhost` : vu d'un conteneur, `localhost` est le conteneur lui-même | API sur `0.0.0.0`, service pointant vers la passerelle du réseau Docker (`172.1.1.1`) |
| `no configuration file provided` | `cd` tapé pendant la demande de mot de passe SSH, donc perdu | Vérifier le répertoire courant dans le prompt |
| Swagger UI blanc via `/api/docs` | `strip_path` retire `/api`, mais la page charge `/openapi.json` sans le préfixe | Côté application : `root_path` de FastAPI |

## Ce que j'en retiens

- **Data plane** (8000, le trafic) et **control plane** (8001, l'administration) sont séparés.
  Une Admin API exposée sans authentification = contrôle total de la gateway.
- Les en-têtes `X-Kong-*` permettent de distinguer la latence du service de celle de la gateway.
- Une gateway centralise les politiques transverses sans toucher aux services.

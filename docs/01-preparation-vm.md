# 01. Préparation de la VM

**Date :** 4-5 octobre 2026

## Objectif

Disposer d'un environnement Linux stable, accessible en SSH, capable de faire tourner
Docker et une stack Kong complète.

## Pourquoi

- **Ubuntu Server plutôt que Kali** : Kali est une distribution de pentest en rolling
  release, non supportée officiellement par Docker. Ubuntu LTS est ce qu'on retrouve chez
  les clients et c'est la cible des documentations Docker et Kong.
- **Kong en conteneur plutôt qu'installé sur l'OS** : environnement jetable et reproductible.

## Ce que j'ai fait

### 1. Accès SSH via le NAT VirtualBox

En NAT, la VM a une IP privée (`10.0.2.15`) injoignable depuis le Mac.
J'ai créé une redirection de port : port 2222 du Mac vers port 22 de la VM.

```bash
VBoxManage controlvm "<VM>" natpf1 "ssh,tcp,127.0.0.1,2222,,22"
ssh -p 2222 manu@127.0.0.1
```

### 2. Ressources

Passage de 1,6 Go à 4 Go de RAM (dans VirtualBox) et ajout de 2 Go de swap :

```bash
sudo fallocate -l 2G /swapfile && sudo chmod 600 /swapfile
sudo mkswap /swapfile && sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

### 3. Docker Engine depuis le dépôt officiel

Le paquet `docker.io` d'Ubuntu est en retard sur les versions officielles. J'ai ajouté
le dépôt Docker (clé GPG + source apt), puis installé `docker-ce`, `docker-compose-plugin`
et `docker-buildx-plugin`.

```bash
sudo usermod -aG docker $USER   # Docker sans sudo
docker run hello-world          # image arm64v8 tirée automatiquement
```

### 4. Mises à jour et noyau

```bash
sudo apt update && sudo apt upgrade -y
sudo reboot     # chargement du nouveau noyau
```

### 5. Confort

`jq` (lecture et filtrage du JSON de l'Admin API), `httpie`, `bat`, `eza`.

## Résultat

VM Ubuntu 26.04.1 arm64, 4 Go RAM + 2 Go swap, Docker opérationnel sans sudo, accès SSH stable.

## Problèmes rencontrés et solutions

| Symptôme | Cause | Solution |
|---|---|---|
| `Connection refused` sur `127.0.0.1:2222` | Aucune règle de redirection NAT : rien n'écoutait sur le port du Mac | Ajout de la règle `natpf1` |
| `Bad port` | `-p` sans numéro de port | `ssh -p 2222 user@host` |
| Mot de passe de la VM perdu | — | Démarrage GRUB avec `rw init=/bin/bash`, puis `passwd` |
| Risque d'OOM (1,6 Go, pas de swap) | Ressources par défaut trop faibles pour Kong + Postgres + supervision | 4 Go RAM + 2 Go swap |

## Ce que j'en retiens

- `Connection refused` = rien n'écoute sur ce port. Un timeout = problème de chemin réseau.
- Être dans le groupe `docker` équivaut à être root : acceptable en lab, à éviter en production (mode rootless).
- Un accès console donne un accès root (GRUB) : en production on chiffre le disque et on protège le chargeur de démarrage.

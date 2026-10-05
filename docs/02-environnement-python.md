# 02. Environnement Python

**Date :** 5 octobre 2026

## Objectif

Installer les dépendances de l'API FastAPI de démonstration.

## Pourquoi

L'API sert de backend derrière Kong. Elle doit tourner dans un environnement isolé,
sans toucher au Python du système.

## Ce que j'ai fait

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
uv venv --python 3.12
source .venv/bin/activate
uv pip install -r requirements.txt
python main.py
```

## Résultat

Python 3.12.15 dans un environnement virtuel, 13 paquets installés en quelques millisecondes,
API démarrée.

## Problèmes rencontrés et solutions

| Symptôme | Cause | Solution |
|---|---|---|
| `error: externally-managed-environment` | PEP 668 : Ubuntu protège le Python du système, dont dépendent des outils de l'OS | Environnement virtuel |
| Échec de compilation de `pydantic-core 2.16.3` (`ForwardRef._evaluate() missing ... 'recursive_guard'`) | Ubuntu 26.04 fournit Python 3.14. Aucun wheel précompilé n'existe pour cette version : pip compile le code Rust, et le script de build de cette ancienne version est incompatible avec Python 3.14 | `uv` télécharge Python 3.12, pour lequel les wheels existent |

## Ce que j'en retiens

- Quand pip compile du Rust ou du C, c'est presque toujours qu'il ne trouve pas de wheel pour ma version de Python.
- On reproduit l'environnement prévu par un projet plutôt que de monter ses dépendances.
- `uv` remplace pip, venv et pyenv, et gère plusieurs versions de Python sans toucher au système.
- `--break-system-packages` : ne pas utiliser.

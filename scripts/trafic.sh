#!/usr/bin/env bash
# Génère du trafic réaliste pour alimenter les tableaux de bord.
# Usage : bash scripts/trafic.sh [durée en secondes, défaut 120]
set -uo pipefail

cd "$(dirname "$0")/.."
set -a; source .env; set +a

DURATION="${1:-120}"
URL="http://localhost:8000/api/healthy"
END=$((SECONDS + DURATION))

echo "Trafic pendant ${DURATION}s (Ctrl+C pour arrêter)..."
while [ $SECONDS -lt $END ]; do
  curl -s -o /dev/null -H "apikey: $DECK_GOLD_KEY" "$URL" &
  curl -s -o /dev/null -H "apikey: $DECK_GOLD_KEY" "$URL" &
  curl -s -o /dev/null -H "apikey: $DECK_FREE_KEY" "$URL" &   # dépasse vite 5/min : 429
  curl -s -o /dev/null "$URL" &                               # sans clé : 401
  wait
  sleep 0.5
done
echo "Terminé."

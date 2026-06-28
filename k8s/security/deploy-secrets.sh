#!/bin/bash
set -e

NAMESPACE="receitas-app"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/../../../../Api-receitas" && pwd)"

echo "Creating JWT keys Secret in namespace $NAMESPACE..."

kubectl create secret generic jwt-keys \
  -n "$NAMESPACE" \
  --from-file=app.key="$REPO_DIR/api/src/main/resources/app.key" \
  --from-file=app.pub="$REPO_DIR/api/src/main/resources/app.pub" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Done. jwt-keys Secret created/updated."

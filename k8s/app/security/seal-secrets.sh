#!/bin/bash
set -e

NAMESPACE="receitas-app"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/../../../../dev/java/Api-receitas" && pwd)"

if ! command -v kubeseal &>/dev/null; then
  echo "Erro: kubeseal não encontrado. Instale com:"
  echo "  wget https://github.com/bitnami-labs/sealed-secrets/releases/latest/download/kubeseal-linux-amd64"
  echo "  sudo install -m 755 kubeseal-linux-amd64 /usr/local/bin/kubeseal"
  exit 1
fi

echo "=== JWT Keys ==="
KEY_FILE="$REPO_DIR/api/src/main/resources/app.key"
PUB_FILE="$REPO_DIR/api/src/main/resources/app.pub"

if [ ! -f "$KEY_FILE" ] || [ ! -f "$PUB_FILE" ]; then
  echo "Erro: arquivos de chave não encontrados em $REPO_DIR/api/src/main/resources/"
  exit 1
fi

kubectl create secret generic jwt-keys \
  -n "$NAMESPACE" \
  --from-file=app.key="$KEY_FILE" \
  --from-file=app.pub="$PUB_FILE" \
  --dry-run=client -o yaml |
  kubeseal \
    --controller-name=sealed-secrets \
    --controller-namespace=kube-system \
    --format=yaml \
    >"$SCRIPT_DIR/jwt-sealedsecret.yaml"

echo "Salvo: $SCRIPT_DIR/jwt-sealedsecret.yaml"

echo ""
echo "=== PostgreSQL Credentials ==="

kubectl create secret generic postgres-credentials \
  -n "$NAMESPACE" \
  --from-literal=username=admin \
  --from-literal=password=admin123 \
  --dry-run=client -o yaml |
  kubeseal \
    --controller-name=sealed-secrets \
    --controller-namespace=kube-system \
    --format=yaml \
    >"$SCRIPT_DIR/postgres-sealedsecret.yaml"

echo "Salvo: $SCRIPT_DIR/postgres-sealedsecret.yaml"

echo ""
echo "Pronto! Ambos os SealedSecrets podem ser versionados no git."

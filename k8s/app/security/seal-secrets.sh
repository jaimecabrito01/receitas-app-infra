#!/bin/bash
set -e

NAMESPACE="receitas-app"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
KEYS_DIR="$SCRIPT_DIR/jwt-keys"

if ! command -v kubeseal &>/dev/null; then
  echo "Erro: kubeseal não encontrado. Instale com:"
  echo "  wget https://github.com/bitnami-labs/sealed-secrets/releases/latest/download/kubeseal-linux-amd64"
  echo "  sudo install -m 755 kubeseal-linux-amd64 /usr/local/bin/kubeseal"
  exit 1
fi

echo "=== JWT Keys ==="
mkdir -p "$KEYS_DIR"

if [ ! -f "$KEYS_DIR/app.key" ] || [ ! -f "$KEYS_DIR/app.pub" ]; then
  echo "Gerando par de chaves JWT em $KEYS_DIR"
  openssl genrsa -out "$KEYS_DIR/app.key" 2048
  openssl rsa -in "$KEYS_DIR/app.key" -pubout -out "$KEYS_DIR/app.pub"
else
  echo "Usando chaves existentes em $KEYS_DIR"
fi

kubectl create secret generic jwt-keys \
  -n "$NAMESPACE" \
  --from-file=app.key="$KEYS_DIR/app.key" \
  --from-file=app.pub="$KEYS_DIR/app.pub" \
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

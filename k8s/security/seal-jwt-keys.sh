#!/bin/bash
set -e

NAMESPACE="receitas-app"
SECRET_NAME="jwt-keys"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_FILE="$SCRIPT_DIR/jwt-sealedsecret.yaml"

REPO_DIR="$(cd "$SCRIPT_DIR/../../../../dev/java/Api-receitas" && pwd)"
KEY_FILE="$REPO_DIR/api/src/main/resources/app.key"
PUB_FILE="$REPO_DIR/api/src/main/resources/app.pub"

if [ ! -f "$KEY_FILE" ] || [ ! -f "$PUB_FILE" ]; then
  echo "Erro: arquivos de chave não encontrados em $REPO_DIR/api/src/main/resources/"
  exit 1
fi

if ! command -v kubeseal &>/dev/null; then
  echo "Erro: kubeseal não encontrado. Instale com:"
  echo "  wget https://github.com/bitnami-labs/sealed-secrets/releases/latest/download/kubeseal-linux-amd64"
  echo "  sudo install -m 755 kubeseal-linux-amd64 /usr/local/bin/kubeseal"
  exit 1
fi

echo "Gerando SealedSecret para $SECRET_NAME no namespace $NAMESPACE..."

kubectl create secret generic "$SECRET_NAME" \
  -n "$NAMESPACE" \
  --from-file=app.key="$KEY_FILE" \
  --from-file=app.pub="$PUB_FILE" \
  --dry-run=client -o yaml |
  kubeseal \
    --controller-name=sealed-secrets \
    --controller-namespace=kube-system \
    --format=yaml \
    >"$OUTPUT_FILE"

echo "SealedSecret salvo em: $OUTPUT_FILE"
echo "Pronto para versionar no git e aplicar com ArgoCD."

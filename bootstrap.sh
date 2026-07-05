#!/bin/bash
set -e

echo "=== 1. Namespace argocd ==="
kubectl create namespace argocd 2>/dev/null || true

echo "=== 2. Instalando ArgoCD ==="
kubectl apply --server-side --force-conflicts -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "=== 3. Aguardando ArgoCD ==="
kubectl wait --for=condition=available --timeout=180s -n argocd deployment/argocd-server

echo "=== 4. Instalando SealedSecrets controller ==="
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/latest/download/controller.yaml

echo "=== 5. Aplicando Applications ==="
kubectl apply -f k8s/argocd/applications.yaml

echo ""
echo "=== Pronto! ArgoCD esta sincronizando a Application ==="
echo "Para acessar o ArgoCD: kubectl get svc argocd-server-lb -n argocd"

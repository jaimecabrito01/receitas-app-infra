#!/bin/bash
set -e

echo "=== 1. Namespace argocd ==="
kubectl create namespace argocd 2>/dev/null || true

echo "=== 2. Instalando ArgoCD ==="
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "=== 3. Aguardando ArgoCD ==="
kubectl wait --for=condition=available --timeout=180s -n argocd deployment/argocd-server

echo "=== 4. Instalando SealedSecrets controller ==="
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/latest/download/controller.yaml

echo "=== 5. Instalando CRDs do Traefik ==="
kubectl apply -f https://raw.githubusercontent.com/traefik/traefik/v3.1/docs/content/reference/dynamic-configuration/kubernetes-crd-definition-v1.yml

echo "=== 6. Aplicando Applications ==="
kubectl apply -f k8s/argocd/applications.yaml

echo ""
echo "=== Pronto! ArgoCD esta sincronizando os Applications ==="
echo "Para acessar o dashboard: kubectl port-forward -n argocd svc/argocd-server 8080:443"

# receitas-app-infra

GitOps repo for a recipe app stack (Vue.js frontend + Spring Boot API + PostgreSQL) deployed on a Kubernetes cluster via ArgoCD.

## Structure

- `k8s/app/` — main app manifests (namespace: `receitas-app`)
  - `deployment.yml` — Spring Boot backend (image `ghcr.io/jaimecabrito01/Api-receitas-backend:latest`, port 8080)
  - `frontend.yml` — Vue.js frontend Deployment (image `ghcr.io/jaimecabrito01/api-receitas-frontend:latest`, port 80) + ClusterIP Service (port 80)
  - `db/postgresql.yaml` — PostgreSQL 15-alpine StatefulSet, PVC (2Gi), ClusterIP Service (port 5432)
    - DB name: `energia_db`; credentials from Secret `postgres-credentials` (keys: `username`, `password`)
  - `db/postgres-secret.yaml` — Secret `postgres-credentials` (namespace `receitas-app`)
    - **Apenas para dev local.** Não commitar secrets reais no repo.
- `k8s/namespaces/energia.yml` — separate `energia-slz` namespace (unrelated to the main app)

## Missing manifests

The backend has a ClusterIP Service (`receitas-app-service:8080`) but **no Ingress**. No external route yet.

## ArgoCD sync-wave order

Resources annotated with `argocd.argoproj.io/sync-wave` to enforce creation order:

| Wave | Resources |
|------|-----------|
| `"0"` | Namespace `receitas-app` |
| `"1"` | Secret `postgres-credentials`, PVC `postgres-pvc` |
| `"2"` | Deployments (backend, frontend), StatefulSet (PostgreSQL) |
| `"3"` | ClusterIP Services (postgres, backend, frontend) |

## Deploy

ArgoCD syncs from the `k8s/` directory in this repo. No CI workflows in-repo.

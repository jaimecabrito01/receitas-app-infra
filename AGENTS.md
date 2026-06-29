# receitas-app-infra

GitOps repo for a recipe app stack (Vue.js frontend + Spring Boot API + PostgreSQL) deployed via ArgoCD.

## Entry point

`k8s/app/kustomization.yaml` — the Kustomize root ArgoCD syncs from `k8s/`.

## Secrets

Bitnami SealedSecrets, **not** plain Secrets. Regenerate locally with:

```bash
./k8s/app/security/seal-secrets.sh
```

Requires `kubeseal` and a running cluster with the SealedSecrets controller in `kube-system`.

- `postgres-sealedsecret.yaml` — DB credentials (`username`, `password` for `energia_db`)
- `jwt-sealedsecret.yaml` — JWT keypair (`app.key`, `app.pub`) mounted at `/etc/jwt` by the backend

## Namespaces

Two namespace manifests exist; the wave `-1` one (`k8s/namespaces/receitas-app.yml`) bootstraps the namespace before Kustomize applies wave `0` resources:

| Wave | Scope |
|------|-------|
| `"-1"` | `k8s/namespaces/receitas-app.yml` — namespace bootstrap |
| `"0"` | Everything in `k8s/app/kustomization.yaml` (deployments, services, PVC, StatefulSet, SealedSecrets) |

## Architecture

- **Backend** — `ghcr.io/jaimecabrito01/api-receitas-backend:latest`, port 8080, ClusterIP `receitas-app-service`. Connects to `postgres-service:5432/energia_db`. Mounts JWT keys from SealedSecret.
- **Frontend** — `ghcr.io/jaimecabrito01/api-receitas-frontend:latest`, port 80, ClusterIP `receitas-app-frontend-service`.
- **PostgreSQL** — `postgres:15-alpine` StatefulSet with PVC (2Gi), ClusterIP `postgres-service:5432`.
- **No Ingress yet** — Traefik is expected as the ingress controller (from README diagram).

## Deploy

ArgoCD auto-syncs from this repo. No CI workflows live here — GitHub Actions builds images to GHCR externally.

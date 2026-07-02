# receitas-app-infra

GitOps repo for a recipe app stack (Vue.js frontend + Spring Boot API + PostgreSQL) deployed via ArgoCD.

## Entry points

Two independent Kustomize roots, each synced by a separate ArgoCD Application:

| Application | Root | What it deploys |
|---|---|---|
| `receitas-app` | `k8s/app/kustomization.yaml` | Frontend + Backend + PostgreSQL + SealedSecrets + IngressRoute |
| `traefik` | `k8s/traefik/kustomization.yaml` | Traefik ingress controller (v3.1, LoadBalancer) |

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
| `"0"` | Everything in `k8s/app/kustomization.yaml` (deployments, services, PVC, StatefulSet, SealedSecrets, IngressRoute) |

The `traefik` namespace is created by `k8s/traefik/namespace.yaml`.

## Architecture

- **Traefik** — `traefik:v3.1`, LoadBalancer Service (ports 80/443), provider `kubernetescrd`. Deployed from `k8s/traefik/`.
- **IngressRoute** — `k8s/app/ingressroute.yaml` routes catch-all HTTP → `receitas-app-frontend-service:80`.
- **Backend** — `ghcr.io/jaimecabrito01/api-receitas-backend:latest`, port 8080, ClusterIP `receitas-app-service`. Connects to `postgres-service:5432/energia_db`. Mounts JWT keys from SealedSecret.
- **Frontend** — `ghcr.io/jaimecabrito01/api-receitas-frontend:latest`, port 80, ClusterIP `receitas-app-frontend-service`.
- **PostgreSQL** — `postgres:15-alpine` StatefulSet with PVC (2Gi), ClusterIP `postgres-service:5432`.

## Deploy


## Bootstrap (cluster novo)



```bash

git clone git@github.com:jaimecabrito01/receitas-app-infra.git

cd receitas-app-infra

./bootstrap.sh

```



Instala ArgoCD + SealedSecrets + Traefik CRDs e cria os Applications.


ArgoCD auto-syncs from this repo (two Applications). No CI workflows live here — GitHub Actions builds images to GHCR externally.

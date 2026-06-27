# EnergIA-slz-fullstack-infra
flowchart TB

    USER[Usuário]

    GH[GitHub]
    GHA[GitHub Actions]
    CR[GHCR / Docker Registry]
    ARGO[ArgoCD]

    USER --> TRAEFIK

    GH --> GHA
    GHA --> CR
    CR --> ARGO

    subgraph K8S["Kubernetes Cluster"]

        TRAEFIK[Traefik Ingress Controller]

        subgraph APP["Namespace: energia-slz"]

            SPRING[Spring Boot API]

            MONGO[(MongoDB StatefulSet)]

        end

        subgraph OPS["Namespace: argocd"]

            ARGO_INTERNAL[ArgoCD]

        end

        TRAEFIK --> SPRING
        SPRING --> MONGO

    end

    ARGO --> ARGO_INTERNAL

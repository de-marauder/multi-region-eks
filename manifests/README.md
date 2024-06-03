# Continous Deployment Strategy

ArgoCD is being used a sthe tool of choice here. It comes with a GUI which you can use to visualize your deployments. It also allows you to do some other cool stuff like deploy to multiple different clusters.

Another tool that could be used is fluxCD but i prefare argoCD mostly because of it's UI.

## Directory structure
```
manifests/
├── argocd
│   ├── consul.yaml
│   ├── gen-algo.yaml
│   └── vault.yaml
├── base
│   ├── api-deployment.yaml
│   ├── api-service.yaml
│   ├── kustomization.yaml
│   ├── namespace.yaml
│   ├── serviceAccount.yaml
│   ├── webui-deployment.yaml
│   └── webui-service.yaml
├── helm
│   ├── dev
│   │   ├── consul-values.yml
│   │   └── vault-values.yml
│   └── prod
├── overlays
│   ├── development
│   │   ├── us-east-1
│   │   │   ├── api-deployment-patch.yaml
│   │   │   ├── kustomization.yaml
│   │   │   └── webui-deployment-patch.yaml
│   │   └── us-east-2
│   └── production
└── README.md
```
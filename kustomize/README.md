# Kustomize

Demonstrates Kustomize's base + overlays pattern for managing environment-specific Kubernetes configurations without templating.

## What's Included

- `base/` - Shared resources: Namespace, Deployment, and Service with common labels
- `overlays/dev/` - Dev overlay (1 replica, `env: dev` label)
- `overlays/staging/` - Staging overlay (1 replica, `env: staging` label)
- `overlays/prod/` - Prod overlay (5 replicas, `env: prod` label)

## How It Works

The base defines the common configuration. Each overlay references the base and applies patches (e.g., changing replica count) and additional labels for the target environment.

## Deploy

```sh
# Preview the rendered manifests
kubectl kustomize overlays/dev

# Apply to cluster
kubectl apply -k overlays/dev
kubectl apply -k overlays/staging
kubectl apply -k overlays/prod
```

## Teardown

```sh
kubectl delete -k overlays/dev
```

# Helm + Kustomize Example

This example demonstrates how to use a custom Helm chart with Kustomize overlays for environment-specific configuration.

## Directory Structure

```
helm-kustomize-example/
  base/
    nginx-helm-chart/
      Chart.yaml
      values.yaml
      templates/
        _helpers.tpl
        deployment.yaml
        service.yaml
  overlays/
    dev/
      kustomization.yaml
      values-dev.yaml
    staging/
      kustomization.yaml
      values-staging.yaml
    prod/
      kustomization.yaml
      values-prod.yaml
```

## How It Works

- The base directory contains a custom NGINX Helm chart with configurable replicas, service type, resource limits, and health probes.
- Each overlay (dev, staging, prod) customizes the Helm release using its own `values-*.yaml` file.
- Kustomize's `helmCharts` field is used to render the Helm chart with environment-specific values.

## Environment Configuration

| Setting | Dev | Staging | Prod |
|---|---|---|---|
| Replicas | 2 | 3 | 5 |
| Service Type | NodePort | ClusterIP | LoadBalancer |
| Service Port | 80 (nodePort: 30080) | 80 | 80 |

## Deploy

```sh
# Preview the rendered manifests
kubectl kustomize overlays/dev --enable-helm

# Apply to cluster
kubectl apply -k overlays/dev --enable-helm
kubectl apply -k overlays/staging --enable-helm
kubectl apply -k overlays/prod --enable-helm
```

## Teardown

```sh
kubectl delete -k overlays/dev --enable-helm
```

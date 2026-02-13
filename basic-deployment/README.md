# Basic Deployment

A simple Kubernetes deployment using plain YAML manifests. This is the most straightforward approach — no templating tools required.

## What's Included

- `namespace.yaml` - Creates the `example` namespace
- `deployment.yaml` - Nginx deployment with 3 replicas, resource limits, and health probes
- `service.yaml` - LoadBalancer service exposing port 80

## Deploy

```sh
kubectl apply -f namespace.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

## Teardown

```sh
kubectl delete -f service.yaml
kubectl delete -f deployment.yaml
kubectl delete -f namespace.yaml
```

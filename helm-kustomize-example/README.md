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

- The base directory contains a custom NGINX Helm chart.
- Each overlay (dev, staging, prod) customizes the Helm release using its own `values-*.yaml` file.
- Kustomize's `helmCharts` field is used to render the Helm chart with environment-specific values.

## Example: Deploying the Dev Environment

```sh
kubectl kustomize helm-kustomize-example/overlays/dev
kubectl apply -k helm-kustomize-example/overlays/dev
```

## Example: overlays/dev/kustomization.yaml

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
helmCharts:
  - name: nginx-helm-chart
    releaseName: nginx-dev
    version: 0.1.0
    repo: "file://../../base/nginx-helm-chart"
    valuesFile: values-dev.yaml
```

## Example: overlays/dev/values-dev.yaml

```yaml
replicaCount: 2
image:
  tag: "1.21"
service:
  type: NodePort
  port: 30080
```

## Example: base/nginx-helm-chart/values.yaml

```yaml
replicaCount: 1
image:
  repository: nginx
  tag: "1.21"
  pullPolicy: IfNotPresent
service:
  type: ClusterIP
  port: 80
```

## Example: base/nginx-helm-chart/templates/deployment.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "nginx.deployment.name" . }}
  labels:
    app: {{ include "nginx.fullname" . }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ include "nginx.fullname" . }}
  template:
    metadata:
      labels:
        app: {{ include "nginx.fullname" . }}
    spec:
      containers:
        - name: nginx
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          ports:
            - containerPort: 80
```

## Example: base/nginx-helm-chart/templates/service.yaml

```yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ include "nginx.service.name" . }}
  labels:
    app: {{ include "nginx.fullname" . }}
spec:
  type: {{ .Values.service.type }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: 80
  selector:
    app: {{ include "nginx.fullname" . }}
```

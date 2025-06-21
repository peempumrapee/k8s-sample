# k8s-sample Project

This repository serves as a sample project to demonstrate how to structure and manage Kubernetes configurations, progressing from basic static manifests to a scalable Kustomize-based setup.

## Prerequisites

Before you begin, ensure you have the following tools installed:
*   [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/): The Kubernetes command-line tool.
*   [Kustomize](https://kustomize.io/): A tool for customizing Kubernetes configurations. `kubectl` version 1.14+ includes a version of Kustomize.

## Project Structure

The project is organized into two main directories:

```
.
├── basic-deployment/   # Simple, static Kubernetes manifests
│   ├── deployment.yaml
│   ├── namespace.yaml
│   └── service.yaml
└── kustomize/          # Kustomize-based configuration management
    ├── base/           # Common resources and configurations for all environments
    │   ├── deployment.yaml
    │   ├── kustomization.yaml
    │   ├── namespace.yaml
    │   └── service.yaml
    └── overlays/       # Environment-specific customizations
        └── staging/
            ├── kustomization.yaml
            └── replicas.yaml
```

*   **`basic-deployment`**: This directory contains a straightforward set of Kubernetes YAML files. It's a good starting point for understanding the basic resources needed to deploy an application.

*   **`kustomize`**: This directory showcases a more advanced and maintainable way to manage configurations for multiple environments.
    *   **`base/`**: Contains the foundational, environment-agnostic Kubernetes manifests. These manifests are templates that will be customized by overlays.
    *   **`overlays/`**: Each subdirectory within `overlays` represents a specific environment (e.g., `staging`, `production`). These overlays apply patches to the `base` configuration to tailor it for the target environment.

## How to Use

### 1. Basic Deployment

This approach is suitable for simple use cases or for getting started quickly.

To deploy the application using the basic manifests, first ensure the namespace exists, then apply all files in the directory:

```sh
# Apply the namespace first
kubectl apply -f basic-deployment/namespace.yaml

# Apply the rest of the resources
kubectl apply -f basic-deployment/
```

### 2. Kustomize for Environment Management

This is the recommended approach for managing multiple environments like `dev`, `staging`, and `production`.

#### Applying the Staging Environment

You can preview the final Kubernetes manifests that Kustomize will generate for the `staging` environment without applying them:

```sh
kubectl kustomize kustomize/overlays/staging
```

To deploy the `staging` configuration to your cluster, use the `-k` flag:

```sh
kubectl apply -k kustomize/overlays/staging
```
This command reads `kustomize/overlays/staging/kustomization.yaml`, builds the resources by applying the staging patches to the `base` configuration, and then applies them to the cluster.

## Managing Environments (Dev, Staging, Prod)

The power of Kustomize lies in its ability to manage environment differences cleanly.

### How to Add a New Environment (e.g., Production)

Let's create a `production` environment with 5 replicas.

**1. Create the directory structure:**

```sh
mkdir -p kustomize/overlays/production
```

**2. Create a `kustomization.yaml` for production:**

Create a file at `kustomize/overlays/production/kustomization.yaml` with the following content:

```yaml
apiVersion: kustomize.config.k8s.io/v1
kind: Kustomization
bases:
  - ../../base

commonLabels:
  env: production

patches:
- path: replicas.yaml
```

**3. Create a patch file for production-specific settings:**

Create a file at `kustomize/overlays/production/replicas.yaml` to override the replica count:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: example-deployment
spec:
  replicas: 5
```

**4. Deploy the Production Environment:**

You can now deploy the `production` environment just like you did for `staging`:

```sh
# Preview the production configuration
kubectl kustomize kustomize/overlays/production

# Apply the production configuration
kubectl apply -k kustomize/overlays/production
```

Using this pattern, you can easily add more environments (`dev`, `qa`, etc.) or introduce more complex patches for things like resource limits, ConfigMaps, or different image tags for each environment.

---

## Helm + Kustomize Example

This example demonstrates how to use a custom Helm chart with Kustomize overlays for environment-specific configuration.

### Directory Structure

```text
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

### How It Works

- The base directory contains a custom NGINX Helm chart.
- Each overlay (dev, staging, prod) customizes the Helm release using its own `values-*.yaml` file.
- Kustomize's `helmCharts` field is used to render the Helm chart with environment-specific values.

### Example: Deploying the Dev Environment

```sh
kubectl kustomize helm-kustomize-example/overlays/dev
kubectl apply -k helm-kustomize-example/overlays/dev
```

### Example: overlays/dev/kustomization.yaml

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

### Example: overlays/dev/values-dev.yaml

```yaml
replicaCount: 2
image:
  tag: "1.21"
service:
  type: NodePort
  port: 30080
```

### Example: base/nginx-helm-chart/values.yaml

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

### Example: base/nginx-helm-chart/templates/deployment.yaml

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

### Example: base/nginx-helm-chart/templates/service.yaml

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
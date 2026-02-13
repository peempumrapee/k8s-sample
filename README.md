# K8s Sample Project

This repository contains various examples of Kubernetes configurations, demonstrating different approaches to deploying and managing applications.

## Project Structure

- `basic-deployment/`: Simple, standalone Kubernetes deployment using plain YAML manifests. No templating tools required.
- `kustomize/`: Demonstrates Kustomize's base + overlays pattern for managing environment-specific configurations (dev/staging/prod).
- `helm-kustomize-example/`: Combines Helm charts with Kustomize overlays, showing how to use Helm for templating and Kustomize for environment management.
- `dagster-deployment/`: Example of deploying Dagster (a data orchestration platform) on Kubernetes using the official Helm chart with Kustomize overlays.

## Getting Started

Each directory contains its own `README.md` with specific instructions on how to deploy and manage the applications.

## Prerequisites

- Kubernetes cluster (e.g., Minikube, Docker Desktop Kubernetes, or a cloud-based cluster)
- `kubectl` installed and configured
- `kustomize` (if working with Kustomize examples)
- `helm` (if working with Helm examples)

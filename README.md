# Docker, Kubernetes & CI/CD Practice

A personal container/DevOps lab using a Vite frontend, multi-stage Docker build, GitHub Actions, GitHub Container Registry (GHCR), Trivy scanning, and Kubernetes/Prometheus configuration.

> This repository demonstrates CI and Kubernetes manifests. It does **not** implement automatic deployment to a live Kubernetes cluster or claim enterprise/AKS production use.

## Pipeline and components

```text
Git push to master
  └─ GitHub Actions
      ├─ Build Docker image (Node/Vite → Nginx)
      ├─ Publish image to GHCR (latest + commit SHA)
      └─ Scan published image with Trivy (HIGH/CRITICAL)

Kubernetes (manual deployment)
  ├─ Deployment: 4 Nginx frontend replicas
  ├─ nginx-prometheus-exporter sidecar
  ├─ Service: HTTP + metrics
  ├─ ServiceMonitor: Prometheus Operator discovery
  └─ PrometheusRule: app availability alert
```

## Repository contents

- `Dockerfile`: multi-stage application build and Nginx image.
- `nginx.conf`: SPA fallback and Nginx status endpoint.
- `.github/workflows/CI.yml`: image build, GHCR publish, Trivy scan.
- `k8s/deployment.yml`: Deployment, exporter sidecar, and Service.
- `k8s/servicemonitor.yml` and `k8s/prometheusrule.yml`: monitoring and alert configuration.

## Build locally

```bash
docker build -t frontend-app:local .
docker run --rm -p 8080:80 frontend-app:local
# Open http://localhost:8080
```

## Kubernetes setup (manual)

1. Prepare a Kubernetes cluster with `kubectl` access.
2. Install a compatible Prometheus Operator stack if using `ServiceMonitor`/`PrometheusRule`.
3. Update the image reference in `k8s/deployment.yml` to an image that exists in your registry.
4. If the image is private, create an image pull secret named `ghcr-secret` in the deployment namespace; otherwise remove the `imagePullSecrets` reference.
5. Apply the manifests and verify the workloads:

```bash
kubectl apply -f k8s/deployment.yml
kubectl get deployment,svc,pods
kubectl apply -f k8s/servicemonitor.yml
kubectl apply -f k8s/prometheusrule.yml
```

The monitoring manifests assume a Prometheus release label `release: monitoring` and a default application namespace. Adapt these selectors to your cluster.

## CI evidence

[Successful build and image publishing run](https://github.com/SunTao2022/frontend-app/actions/runs/32654323711).

## Known limitations / next steps

- The current workflow publishes **before** the Trivy scan. A failing scan blocks the CI job but does not roll back an already-pushed image.
- Deployment manifests pin a specific image SHA and are **not** automatically updated by CI.
- Add readiness/liveness probes and resource settings for the primary application container.
- Pin the Trivy GitHub Action to a reviewed version or commit; evaluate using GitHub's short-lived token for GHCR where appropriate.
- Confirm that the Nginx exporter can access `stub_status` and that Prometheus correctly discovers the metrics Service.

## Author

[Tao Sun](https://www.linkedin.com/in/tao-sun-3437462b6/) · [GitHub](https://github.com/SunTao2022)

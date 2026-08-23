# SecureShip — End-to-End DevSecOps + GitOps Platform

```
Developer → GitHub → CI (tests · SonarCloud · Gitleaks · Trivy · Syft)
        → ECR → deploy branch → ArgoCD → EKS (Kyverno) → Prometheus/Grafana/Loki
```

Full plan: [PLAN.md](PLAN.md) · Spec: [SecureShip_DevSecOps_GitOps_Project.md](SecureShip_DevSecOps_GitOps_Project.md)

## Quick start

```bash
npm ci
docker compose up --build
# gateway :8000  orders :8001  tracking :8002  notify :8003
```

## Repo layout

- `services/` — 4 Node/Express/TS services
- `helm/secureship/` — umbrella chart
- `environments/{dev,prod}/` — GitOps values (ArgoCD watches `deploy` branch)
- `terraform/{foundation,cluster,bootstrap}/` — AWS infra
- `kyverno/` — admission policies
- `argocd/` — AppProject + Applications

## Branches

| Branch    | Purpose                    |
| --------- | -------------------------- |
| `main`    | Protected, PR required     |
| `develop` | Integration                |
| `deploy`  | ArgoCD target (image tags) |

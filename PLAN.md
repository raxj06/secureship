# SecureShip — Full Build Plan

## Final Tech Decisions

| Concern           | Choice                                                                   |
| ----------------- | ------------------------------------------------------------------------ |
| Backend           | Node.js + Express.js + TypeScript                                        |
| ORM               | Prisma + PostgreSQL                                                      |
| Auth              | Custom JWT (jsonwebtoken), user data in order-service DB                 |
| SAST              | SonarCloud + eslint-plugin-security (lint layer)                         |
| SCA               | Trivy filesystem scan (replaces npm audit)                               |
| Secret Scan       | Gitleaks                                                                 |
| Container Scan    | Trivy                                                                    |
| SBOM              | Syft                                                                     |
| Admission Control | Kyverno (4 policies)                                                     |
| Local dev         | Docker Compose only                                                      |
| AWS region        | ap-south-1                                                               |
| EKS cost mode     | Spot nodes (t3.medium), single NAT GW, RDS single-AZ db.t3.micro         |
| ECR               | Separate repo per service, lifecycle policies                            |
| Image tag         | Git SHA only (no `latest`)                                               |
| Branches          | main + develop + deploy                                                  |
| GitOps target     | `deploy` branch (ArgoCD watches it)                                      |
| AWS auth from CI  | GitHub OIDC role assumption (no static keys)                             |
| Environments      | dev + prod (one cluster, two namespaces)                                 |
| GitOps            | ArgoCD in same EKS cluster                                               |
| Secrets           | .env locally, AWS Secrets Manager + External Secrets Operator in cluster |
| Observability     | Prometheus + Grafana + Loki (kube-prometheus-stack)                      |
| DAST              | OWASP ZAP (against dev ALB)                                              |

---

## AWS Cost Budget: $100 Free Trial

### Cost breakdown estimate (ap-south-1, monthly)

| Resource                       | Approx. cost/month |
| ------------------------------ | ------------------ |
| EKS control plane              | $73                |
| NAT Gateway (1)                | ~$32 + data        |
| ALB                            | ~$16 + LCU         |
| RDS db.t3.micro (single-AZ)    | ~$12               |
| ECR (4 repos, minimal storage) | ~$1                |
| S3 (TF state)                  | <$1                |
| Spot instances (2x t3.medium)  | ~$15               |
| **Total running**              | **~$150/month**    |

### Strategy to stay under $100

1. **Never leave the cluster running overnight.** `terraform destroy -target=module.cluster` after each session.
2. **Keep `foundation/` up permanently** — ECR + OIDC provider costs <$2/month.
3. **Batch work into 2-3 sessions** of 4-6 hours. EKS bills per-hour for the control plane (~$0.10/hr).
4. **Destroy RDS with the cluster** — data is ephemeral for a portfolio project; seed on boot.
5. **Target ~40 hours of cluster uptime total** = ~$60-70 for control plane + NAT + ALB + compute.
6. **Use `terraform plan` liberally** before apply — mistakes that require recreating resources burn hours.
7. **Build and test locally with Docker Compose first** — only go to EKS when Compose is green.
8. **ECR lifecycle policy**: keep only 5 images per repo.

### Phased AWS spend

| Phase     | AWS resources needed                    | Estimated cost |
| --------- | --------------------------------------- | -------------- |
| 1-3       | None (local + GitHub Actions free tier) | $0             |
| 4         | ECR + OIDC provider (foundation/)       | <$2            |
| 5         | Same                                    | $0             |
| 6-8       | Full cluster up for testing (~10 hrs)   | ~$25           |
| 9         | ZAP against running cluster (~2 hrs)    | ~$5            |
| 10        | Observability testing (~8 hrs)          | ~$20           |
| 11        | Failure demos + screenshots (~6 hrs)    | ~$15           |
| **Total** |                                         | **~$67**       |

Buffer: ~$33 for mistakes and re-creates.

---

## Branch Strategy

```
main        Protected. Source of truth for code. PRs required + CI pass.
develop     Integration branch. CI runs on push.
deploy      ArgoCD watches this. Contains environments/*/values.yaml.
            CI writes image tags here on successful main push.
            Unprotected (CI writes directly to dev; prod = manual PR).
```

---

## Repo Layout

```
secureship/
├── services/
│   ├── api-gateway/
│   ├── order-service/
│   ├── tracking-service/
│   └── notification-service/
├── helm/secureship/
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
│       ├── deployment.yaml
│       ├── service.yaml
│       ├── ingress.yaml
│       ├── hpa.yaml
│       ├── networkpolicy.yaml
│       ├── serviceaccount.yaml
│       ├── role.yaml
│       ├── rolebinding.yaml
│       └── externalsecret.yaml
├── environments/
│   ├── dev/values.yaml
│   └── prod/values.yaml
├── terraform/
│   ├── foundation/       # ECR, OIDC, CI role, lifecycle policies
│   ├── cluster/          # VPC, EKS, RDS, IRSA roles
│   └── bootstrap/        # helm_release: ALB ctrl, metrics-server, ESO, ArgoCD, Kyverno
├── kyverno/
│   ├── disallow-privileged.yaml
│   ├── require-non-root.yaml
│   ├── require-resource-limits.yaml
│   └── restrict-registries.yaml
├── argocd/
│   ├── project.yaml
│   ├── application-dev.yaml
│   └── application-prod.yaml
├── monitoring/
│   ├── dashboards/
│   └── alerts/
├── .github/workflows/
│   ├── ci.yml
│   ├── release.yml
│   └── dast.yml
├── scripts/
│   ├── seed-db.sh
│   └── destroy-cluster.sh
├── docs/
├── docker-compose.yml
├── sonar-project.properties
├── .gitleaks.toml
├── .trivyignore
├── tsconfig.base.json
├── .eslintrc.js
├── .prettierrc
├── .gitignore
├── .dockerignore
├── PLAN.md
└── README.md
```

---

## Phase 1 — Repo Scaffold

**Goal:** GitHub repo with correct structure, branches, protection, and shared configs.

**Tasks:**

- Create GitHub repo `secureship`
- Push initial structure with `main`, `develop`, and `deploy` branches
- Set branch protection on `main` (require PR + CI pass)
- Add `.gitignore`, `.dockerignore`, root `README.md`
- Add shared configs at repo root:
  - `tsconfig.base.json`
  - `.eslintrc.js` (with `eslint-plugin-security`)
  - `.prettierrc`
  - `.gitleaks.toml`
  - `.trivyignore`
  - `sonar-project.properties`
- Configure npm workspaces in root `package.json`
- Create empty folder structure for all phases

**AWS cost:** $0

---

## Phase 2 — Four Microservices + Docker Compose

**Goal:** All 4 services running locally via Docker Compose with health, readiness, and metrics endpoints.

### Per-service structure

```
service-name/
├── src/
│   ├── app.ts
│   ├── server.ts
│   ├── routes/
│   ├── controllers/
│   ├── middleware/
│   └── prisma/
│       └── schema.prisma   (order-service, tracking-service only)
├── tests/
├── Dockerfile
├── .env.example
├── package.json
└── tsconfig.json
```

### Services

**api-gateway** (port 8000)

- Reverse proxy via `http-proxy-middleware`
- JWT validation middleware (verifies token, forwards user context)
- No DB
- Endpoints: `GET /health`, `GET /ready`, `GET /metrics`

**order-service** (port 8001)

- CRUD: `POST /orders`, `GET /orders/:id`, `GET /orders`, `PATCH /orders/:id`
- Auth: `POST /auth/register`, `POST /auth/login`
- Prisma schema: `User`, `Order`
- Endpoints: `GET /health`, `GET /ready`, `GET /metrics`

**tracking-service** (port 8002)

- `GET /tracking/:orderId`, `POST /tracking/update`
- Prisma schema: `TrackingEvent`
- Endpoints: `GET /health`, `GET /ready`, `GET /metrics`

**notification-service** (port 8003)

- `POST /notify` (email/SMS trigger, SES stubbed locally)
- No DB
- Endpoints: `GET /health`, `GET /ready`, `GET /metrics`

### Endpoints contract

| Endpoint       | Purpose                                         | Used by            |
| -------------- | ----------------------------------------------- | ------------------ |
| `GET /health`  | Liveness probe (process alive)                  | K8s livenessProbe  |
| `GET /ready`   | Readiness probe (DB connected where applicable) | K8s readinessProbe |
| `GET /metrics` | Prometheus scrape (prom-client)                 | ServiceMonitor     |

### Docker Compose

- All 4 services + PostgreSQL (one instance, two schemas: `orders`, `tracking`)
- `.env.example` for DB credentials, JWT secret, ports
- Health checks on all containers
- Base image: `node:20-slim` (not Alpine — Prisma musl engine needs explicit `binaryTargets`)

### Dockerfile requirements

- Multi-stage build (build → runtime)
- Non-root user (`node`)
- No secrets baked in
- Minimal final image
- `HEALTHCHECK` instruction

### Tests

- Jest per service
- Enough coverage to demonstrate Failure Scenario 1 (broken test blocks pipeline)

**AWS cost:** $0

---

## Phase 3 — GitHub Actions CI (no publish)

**Goal:** Automated pipeline on `push: develop` and `pull_request: main`. Does NOT push images.

### Workflow: `.github/workflows/ci.yml`

```
Trigger: push to develop, pull_request to main

Steps:
1. Checkout (fetch-depth: 0, needed for SonarCloud + Gitleaks)
2. Setup Node 20
3. npm ci (workspace root)
4. Lint (ESLint + Prettier check)
5. Type check (tsc --noEmit per service)
6. Jest (all services, with coverage output)
7. SonarCloud analysis (Quality Gate — blocks on fail)
8. Gitleaks (blocks on secret found)
9. Trivy fs scan (HIGH/CRITICAL block)
10. Docker build ×4 (no push)
11. Trivy image scan ×4 (HIGH/CRITICAL block)
12. Syft SBOM ×4 (upload as workflow artifacts)
```

### Security gates

| Tool        | Blocks on                    | Failure scenario |
| ----------- | ---------------------------- | ---------------- |
| Jest        | Any test failure             | §38 Failure 1    |
| SonarCloud  | Quality Gate fail            | §11              |
| Gitleaks    | Any secret detected          | §38 Failure 2    |
| Trivy fs    | HIGH/CRITICAL CVE            | §38 Failure 3    |
| Trivy image | HIGH/CRITICAL CVE            | §38 Failure 4    |
| Syft        | Never blocks (artifact only) | —                |

### Secrets needed in GitHub

- `SONAR_TOKEN` (SonarCloud)
- That's it. No AWS keys — OIDC handles that in Phase 5.

**AWS cost:** $0

---

## Phase 4 — Terraform (AWS Infrastructure)

**Goal:** Provision all AWS resources in ap-south-1, cost-optimized, in layers.

### Layer 1: `terraform/foundation/`

Apply first. Lives permanently. Costs <$2/month.

- 4 ECR repos (one per service) + lifecycle policies (keep 5 images)
- GitHub OIDC identity provider
- IAM role for CI: `secureship-ci-role` (scoped to `repo:<org>/secureship:ref:refs/heads/main`)
  - Permissions: ECR push, Secrets Manager read
- S3 bucket + DynamoDB for remote state (created once manually, then referenced)

### Layer 2: `terraform/cluster/`

Spun up for working sessions. Destroyed after.

- **VPC**: 2 public + 2 private subnets, single NAT gateway, Internet gateway
- **EKS 1.29**: managed node group with spot `t3.medium` (min 2, max 4)
- **RDS**: PostgreSQL 15, single-AZ, `db.t3.micro`, two databases (`orders`, `tracking`)
- **Security groups**: EKS nodes ↔ RDS, ALB ↔ nodes
- **IRSA roles**:
  - Pod ECR pull
  - Secrets Manager access (for ESO)
  - ALB controller
  - SES send (notification-service)

### Layer 3: `terraform/bootstrap/`

Uses `helm_release` resources. Depends on `cluster/` outputs.

- AWS Load Balancer Controller
- metrics-server
- External Secrets Operator
- ArgoCD
- Kyverno

### Key outputs

- EKS cluster endpoint + kubeconfig command
- ECR repo URLs (×4)
- RDS endpoint
- VPC ID / subnet IDs
- OIDC provider ARN
- CI role ARN

**AWS cost:** ~$2 for foundation (permanent). Cluster cost starts accruing only when applied.

---

## Phase 5 — CI Publish + Promotion

**Goal:** On merge to `main`, build secure images, push to ECR, update GitOps deploy branch.

### Workflow: `.github/workflows/release.yml`

```
Trigger: push to main

Steps:
1-11. Same gates as ci.yml (re-run everything — don't trust PR cache)
12. Configure AWS credentials (OIDC role assumption)
13. ECR login
14. Docker push ×4 (tagged with git SHA)
15. Checkout deploy branch
16. Update environments/dev/values.yaml with new image tags
17. Commit and push to deploy branch
```

### Promotion to prod

Manual process:

1. Open PR on `deploy` branch: copy tags from `environments/dev/values.yaml` to `environments/prod/values.yaml`
2. Merge → ArgoCD syncs prod

This gives the environment-promotion interview story without automation complexity.

**AWS cost:** ECR storage (~$0.10 per push)

---

## Phase 6 — Helm Chart

**Goal:** Single umbrella chart deploying all 4 services.

### Chart structure

```
helm/secureship/
├── Chart.yaml
├── values.yaml              ← defaults
└── templates/
    ├── _helpers.tpl
    ├── deployment.yaml      ← loops .Values.services
    ├── service.yaml
    ├── ingress.yaml         ← AWS ALB ingress (one, path-based routing)
    ├── hpa.yaml
    ├── networkpolicy.yaml   ← default deny + explicit allows
    ├── serviceaccount.yaml  ← IRSA annotation
    ├── role.yaml
    ├── rolebinding.yaml
    ├── externalsecret.yaml  ← pulls from AWS Secrets Manager
    └── migrate-job.yaml     ← pre-upgrade hook: prisma migrate deploy
```

### Security context (all pods)

```yaml
securityContext:
  runAsNonRoot: true
  readOnlyRootFilesystem: true
  allowPrivilegeEscalation: false
  capabilities:
    drop: [ALL]
volumeMounts:
  - name: tmp
    mountPath: /tmp
volumes:
  - name: tmp
    emptyDir: {}
```

The `emptyDir` at `/tmp` is required — Prisma and Node both write temp files; without it `readOnlyRootFilesystem` crashloops the pods.

### NetworkPolicy

```
Default: deny all ingress/egress per namespace
Allow:
  internet → ALB → api-gateway (port 8000)
  api-gateway → order-service (8001)
  api-gateway → tracking-service (8002)
  api-gateway → notification-service (8003)
  order-service → RDS (5432)
  tracking-service → RDS (5432)
  notification-service → SES endpoint (443)
  all pods → DNS (kube-dns, port 53)
```

### RBAC

- ServiceAccount per service (IRSA-annotated)
- Role: get/list secrets, get configmaps (namespace-scoped)
- RoleBinding: SA → Role

### HPA

- CPU target: 70%
- Min replicas: 1 (dev), 2 (prod)
- Max replicas: 4

**AWS cost:** $0 (templates only)

---

## Phase 7 — Cluster Bootstrap + ArgoCD

**Goal:** One `terraform apply` installs all cluster addons. ArgoCD auto-syncs from `deploy` branch.

### Bootstrap components (via `terraform/bootstrap/`)

| Component                    | Purpose                                                  |
| ---------------------------- | -------------------------------------------------------- |
| AWS Load Balancer Controller | Creates ALB from Ingress resources                       |
| metrics-server               | Enables HPA                                              |
| External Secrets Operator    | Syncs AWS Secrets Manager → K8s Secrets                  |
| ArgoCD                       | GitOps controller                                        |
| Kyverno                      | Admission policies (installed here, policies in Phase 8) |

### ArgoCD configuration

```
argocd/project.yaml       → SecureShip AppProject (restricted to secureship-* namespaces)
argocd/application-dev.yaml  → watches deploy branch, path: environments/dev + helm/secureship
argocd/application-prod.yaml → watches deploy branch, path: environments/prod + helm/secureship
```

Sync policy: automated, self-heal, prune.

### Rollback strategy

Revert the commit on `deploy` branch → ArgoCD auto-reverts the deployment. This is the §37 demo.

**AWS cost:** Part of cluster runtime.

---

## Phase 8 — Kyverno Policies

**Goal:** Four admission policies enforcing security at the cluster level.

### Policies

| Policy                         | Action                                                    | Failure scenario |
| ------------------------------ | --------------------------------------------------------- | ---------------- |
| `disallow-privileged.yaml`     | Block `privileged: true`                                  | §38 Failure 5    |
| `require-non-root.yaml`        | Block pods without `runAsNonRoot: true`                   | §38 Failure 5    |
| `require-resource-limits.yaml` | Block pods without requests/limits                        | —                |
| `restrict-registries.yaml`     | Allow only `<account>.dkr.ecr.ap-south-1.amazonaws.com/*` | —                |

### Scope

Apply to `secureship-dev` and `secureship-prod` namespaces only. Do NOT apply cluster-wide — it will reject ArgoCD's own pods, Kyverno's pods, and system addons.

### Rollout

1. Deploy with `validationFailureAction: Audit` first
2. Verify all existing pods pass
3. Flip to `Enforce`
4. Test: attempt to deploy a privileged pod → admission denied

**AWS cost:** Part of cluster runtime.

---

## Phase 9 — DAST (OWASP ZAP)

**Goal:** Automated security scan against the running application.

### Workflow: `.github/workflows/dast.yml`

```
Trigger: workflow_dispatch (manual) + weekly schedule

Steps:
1. Configure AWS credentials (OIDC)
2. Get ALB URL from cluster
3. Run ZAP baseline scan against dev ALB
4. Upload ZAP report as artifact
5. Fail on HIGH alerts (configurable)
```

Separated from ArgoCD — a ZAP false positive should not block deployments.

**AWS cost:** ~$5 (cluster must be running)

---

## Phase 10 — Observability

**Goal:** Full monitoring stack with dashboards, logs, and alerts.

### Stack (installed via `terraform/bootstrap/`)

| Component             | Purpose                             |
| --------------------- | ----------------------------------- |
| kube-prometheus-stack | Prometheus + Grafana + Alertmanager |
| Loki                  | Log aggregation                     |
| Promtail              | Log shipping from nodes             |

### Metrics (from `/metrics` endpoints built in Phase 2)

- `http_requests_total` (method, path, status)
- `http_request_duration_seconds` (histogram)
- `orders_created_total`
- `notifications_sent_total`
- Node/pod CPU, memory, restarts (from kube-state-metrics)

### Dashboards

1. **Cluster**: nodes, pods, CPU, memory, restarts, replica availability
2. **Application**: requests/sec, error rate, latency (p50/p95/p99), throughput per service

### Alerts

| Alert               | Condition                      |
| ------------------- | ------------------------------ |
| PodCrashLooping     | restarts > 3 in 5m             |
| HighCPU             | pod CPU > 80% for 5m           |
| HighMemory          | pod memory > 80% for 5m        |
| HighErrorRate       | 5xx > 5% of requests for 5m    |
| ReplicasUnavailable | available < desired for 5m     |
| NodeNotReady        | node condition != Ready for 5m |

Alertmanager → Slack webhook (or Discord).

**AWS cost:** Part of cluster runtime (~$20 for testing sessions).

---

## Phase 11 — Failure Scenarios + Rollback + Documentation

**Goal:** Demonstrate all seven failure scenarios from §38, plus rollback and architecture docs.

### Failure demonstrations

| #   | Scenario                | How to trigger                 | Expected result                                 |
| --- | ----------------------- | ------------------------------ | ----------------------------------------------- |
| 1   | Unit test fails         | Break a test, push             | CI fails, no deploy                             |
| 2   | Secret committed        | Add fake AWS key to code       | Gitleaks blocks                                 |
| 3   | Vulnerable dependency   | Add old lodash version         | Trivy fs blocks                                 |
| 4   | Vulnerable Docker image | Use old base image             | Trivy image blocks                              |
| 5   | Kyverno violation       | Deploy with `privileged: true` | Admission denied                                |
| 6   | Application crash       | Add crash endpoint, call it    | Pod restarts, Prometheus records, Grafana shows |
| 7   | GitOps drift            | `kubectl edit` a deployment    | ArgoCD detects OutOfSync, self-heals            |

### Rollback demo (§37)

1. Deploy version A (working)
2. Deploy version B (broken — e.g., bad health check)
3. Revert commit on `deploy` branch
4. ArgoCD rolls back to version A
5. Screenshot the ArgoCD sync history

### Documentation deliverables

- Architecture diagram (Mermaid or draw.io)
- README with setup instructions
- Per-phase docs in `docs/`
- Screenshots: CI pipeline, Trivy scan, ArgoCD sync, Grafana dashboard, Kyverno rejection, ZAP report
- Troubleshooting guide
- Security model document

**AWS cost:** ~$15 (cluster up for demo recording)

---

## Build Order Summary

| Phase     | Deliverable                     | Branch              | AWS cost    |
| --------- | ------------------------------- | ------------------- | ----------- |
| 1         | Repo scaffold + configs         | develop             | $0          |
| 2         | All 4 services + Docker Compose | develop             | $0          |
| 3         | GitHub Actions CI (no publish)  | develop → PR → main | $0          |
| 4         | Terraform AWS infra             | develop             | ~$2         |
| 5         | CI publish + promotion          | main                | <$1         |
| 6         | Helm charts                     | develop             | $0          |
| 7         | ArgoCD + cluster bootstrap      | develop             | ~$10        |
| 8         | Kyverno policies                | develop             | ~$5         |
| 9         | DAST                            | develop             | ~$5         |
| 10        | Observability                   | develop             | ~$20        |
| 11        | Failure demos + docs            | develop → PR → main | ~$15        |
| **Total** |                                 |                     | **~$58-67** |

**Buffer remaining:** ~$33-42 for mistakes, re-creates, and extended sessions.

---

## Critical Implementation Notes

### Things that will break if you skip them

1. **`emptyDir` at `/tmp`** — without it, `readOnlyRootFilesystem: true` crashloops every pod (Prisma + Node write temp files)
2. **Kyverno namespace scoping** — cluster-wide registry policy rejects system pods
3. **`node:20-slim` not Alpine** — Prisma needs glibc or explicit musl `binaryTargets`
4. **OIDC trust policy** — scope to `repo:<org>/secureship:ref:refs/heads/main` or any branch can assume the role
5. **Prisma migrations in cluster** — need a pre-upgrade hook Job, not init container (init containers don't have network in some CNI configs before pod is scheduled)
6. **SonarCloud + monorepo** — configure `sonar.sources=services` with merged lcov, or one project per service
7. **ECR lifecycle** — without it, old images accumulate and eat storage budget

### What to do between sessions

```bash
# End of session — destroy expensive resources
cd terraform/cluster && terraform destroy -auto-approve
cd ../bootstrap && terraform destroy -auto-approve

# Start of session — bring cluster back (~10 min)
cd terraform/cluster && terraform apply -auto-approve
cd ../bootstrap && terraform apply -auto-approve

# Foundation stays up always (ECR repos, OIDC provider)
```

### Order of `terraform apply`

```
1. foundation/   (once, never destroy)
2. cluster/      (per session)
3. bootstrap/    (per session, after cluster)
```

### Order of `terraform destroy`

```
1. bootstrap/    (first — removes helm releases)
2. cluster/      (second — removes VPC/EKS/RDS)
3. foundation/   (never, unless done with project)
```

---

## Definition of Done (from spec §53)

- [ ] Application runs locally
- [ ] Unit tests pass
- [ ] Docker image builds
- [ ] Container runs as non-root
- [ ] GitHub Actions CI works
- [ ] SonarCloud scan works + Quality Gate
- [ ] Gitleaks works
- [ ] Dependency scan works (Trivy fs)
- [ ] Trivy image scan works
- [ ] Vulnerable image blocks release
- [ ] SBOM is generated (Syft)
- [ ] ECR receives approved images
- [ ] Kubernetes cluster works
- [ ] Helm deployment works
- [ ] Health probes work (liveness + readiness)
- [ ] HPA works
- [ ] RBAC works (Role + RoleBinding)
- [ ] NetworkPolicy works
- [ ] Kyverno blocks invalid workloads
- [ ] GitOps deploy branch works
- [ ] ArgoCD sync works
- [ ] Git change deploys automatically
- [ ] Rollback works
- [ ] Terraform provisions infrastructure
- [ ] Prometheus collects metrics
- [ ] Grafana dashboard works
- [ ] Loki collects/searches logs
- [ ] Alerts work
- [ ] DAST runs against staging
- [ ] Documentation is complete
- [ ] Architecture diagram is included
- [ ] All 7 failure scenarios demonstrated

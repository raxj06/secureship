# SecureShip --- End-to-End DevSecOps + GitOps Project

## 1. Project Overview

**Project Name:** SecureShip

**Goal:** Build a production-style DevOps/DevSecOps platform
demonstrating the complete software delivery lifecycle:

``` text
Developer
   ↓
GitHub
   ↓
CI Pipeline
   ├── Unit Tests
   ├── SAST
   ├── Secret Scanning
   ├── Dependency Scanning
   ├── Docker Build
   ├── Container Image Scanning
   └── SBOM Generation
   ↓
Container Registry
   ↓
GitOps Repository
   ↓
Argo CD
   ↓
Kubernetes
   ├── Kyverno Policies
   ├── RBAC
   ├── NetworkPolicy
   ├── HPA
   └── Secure Workloads
   ↓
Observability
   ├── Prometheus
   ├── Grafana
   └── Loki
```

The project should be implemented as a real working system, not as a
collection of disconnected tools.

The central story is:

> A developer pushes code. CI automatically tests and security-scans it.
> Only a secure image is published. The GitOps repository is updated.
> Argo CD deploys the desired state to Kubernetes. Kubernetes admission
> policies enforce security. Prometheus/Grafana/Loki provide
> observability.

------------------------------------------------------------------------

# 2. Primary Objectives

The finished project must demonstrate:

-   Git and GitHub workflow
-   CI/CD
-   DevSecOps
-   Docker
-   Container image scanning
-   SAST
-   Secret scanning
-   Dependency vulnerability scanning
-   SBOM generation
-   Container registry
-   Kubernetes
-   Helm
-   GitOps
-   Argo CD
-   Infrastructure as Code
-   Terraform
-   AWS
-   Kubernetes security
-   Kyverno
-   RBAC
-   NetworkPolicies
-   Resource requests/limits
-   HPA
-   Monitoring
-   Logging
-   Alerting
-   Troubleshooting
-   Documentation

------------------------------------------------------------------------

# 3. Recommended Technology Stack

  Area                        Technology
  --------------------------- ---------------------------------------
  Application                 Node.js + Express
  Frontend                    Optional React
  Database                    PostgreSQL
  Source Control              Git + GitHub
  CI                          GitHub Actions
  Containerization            Docker
  Registry                    AWS ECR
  Cloud                       AWS
  Kubernetes                  Amazon EKS
  Kubernetes Packaging        Helm
  GitOps                      Argo CD
  IaC                         Terraform
  SAST                        SonarQube
  Secret Scanning             Gitleaks
  Dependency/Image Security   Trivy
  SBOM                        Syft
  Policy Enforcement          Kyverno
  Metrics                     Prometheus
  Dashboards                  Grafana
  Logs                        Loki
  Optional Log Agent          Promtail/Grafana Alloy
  Networking                  Kubernetes Services + NetworkPolicy
  Security                    RBAC + Pod Security Context + Kyverno

Do not add tools merely for resume keyword count. Every tool must have a
clear responsibility.

------------------------------------------------------------------------

# 4. Architecture

## High-Level Architecture

``` text
                           ┌─────────────────┐
                           │    Developer    │
                           └────────┬────────┘
                                    │
                                 git push
                                    │
                                    ▼
                           ┌─────────────────┐
                           │     GitHub      │
                           │ Application Repo│
                           └────────┬────────┘
                                    │
                                    ▼
                      ┌──────────────────────────┐
                      │      GitHub Actions      │
                      │                          │
                      │ 1. Lint                  │
                      │ 2. Unit Tests            │
                      │ 3. SonarQube SAST        │
                      │ 4. Gitleaks              │
                      │ 5. Dependency Scan       │
                      │ 6. Docker Build          │
                      │ 7. Trivy Image Scan      │
                      │ 8. SBOM / Syft           │
                      └────────────┬─────────────┘
                                   │
                             Security PASS
                                   │
                                   ▼
                            ┌─────────────┐
                            │   AWS ECR   │
                            └──────┬──────┘
                                   │
                                   ▼
                         ┌──────────────────┐
                         │ GitOps Repository│
                         │ Helm Values      │
                         └────────┬─────────┘
                                  │
                                  ▼
                            ┌───────────┐
                            │  Argo CD  │
                            └─────┬─────┘
                                  │
                                  ▼
                         ┌─────────────────┐
                         │    AWS EKS      │
                         │   Kubernetes    │
                         └────────┬────────┘
                                  │
                  ┌───────────────┼────────────────┐
                  ▼               ▼                ▼
              Kyverno           HPA          NetworkPolicy
                  │
                  ▼
             Application
                  │
          ┌───────┴────────┐
          ▼                ▼
     Prometheus           Loki
          │                │
          └───────┬────────┘
                  ▼
               Grafana
```

------------------------------------------------------------------------

# 5. Repository Strategy

Use two repositories.

## Repository 1: Application Repository

Example:

``` text
secureship-app/
├── src/
├── tests/
├── Dockerfile
├── package.json
├── package-lock.json
├── sonar-project.properties
├── .dockerignore
├── .gitignore
├── .github/
│   └── workflows/
│       ├── ci.yml
│       └── security.yml
└── README.md
```

This repository contains:

-   Application source
-   Tests
-   Dockerfile
-   CI workflows
-   Application security configuration

## Repository 2: GitOps Repository

Example:

``` text
secureship-gitops/
├── charts/
│   └── secureship/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── deployment.yaml
│           ├── service.yaml
│           ├── ingress.yaml
│           ├── configmap.yaml
│           ├── hpa.yaml
│           ├── networkpolicy.yaml
│           └── serviceaccount.yaml
│
├── environments/
│   ├── dev/
│   │   └── values.yaml
│   └── prod/
│       └── values.yaml
│
└── argocd/
    ├── application-dev.yaml
    └── application-prod.yaml
```

The application repository should not contain the final production
deployment state.

------------------------------------------------------------------------

# 6. Application

Build a simple backend application.

Recommended:

-   Node.js
-   Express
-   PostgreSQL

The application does not need complicated business logic.

Example endpoints:

``` text
GET  /health
GET  /api/products
POST /api/products
GET  /api/orders
GET  /metrics
```

The purpose of the application is to provide a realistic workload for
the DevOps platform.

## Health Endpoints

Implement:

``` text
/health
/ready
```

`/health` should indicate whether the process is alive.

`/ready` should indicate whether the application is ready to receive
traffic.

Kubernetes should use these endpoints for:

-   Liveness probe
-   Readiness probe

------------------------------------------------------------------------

# 7. Docker

Create a production-style Dockerfile.

Requirements:

-   Use a small base image where practical.
-   Use multi-stage builds if appropriate.
-   Do not run as root.
-   Do not hard-code secrets.
-   Use `.dockerignore`.
-   Pin important dependencies where appropriate.
-   Keep the final image minimal.

Example conceptual structure:

``` text
Build Stage
    ↓
Install dependencies
    ↓
Run tests
    ↓
Build application
    ↓
Runtime Stage
    ↓
Non-root user
    ↓
Run application
```

Topics to understand:

-   Docker image
-   Docker container
-   Layers
-   Dockerfile
-   Multi-stage builds
-   `.dockerignore`
-   Container networking
-   Volumes
-   Environment variables
-   Image tags
-   Image digest
-   Container registry

------------------------------------------------------------------------

# 8. Git Workflow

Use feature branches.

Example:

``` text
main
 │
 ├── feature/add-products-api
 ├── feature/add-health-check
 └── fix/database-timeout
```

Workflow:

``` text
Feature Branch
      ↓
Pull Request
      ↓
CI
      ↓
Security Checks
      ↓
Code Review
      ↓
Merge
      ↓
Build Release Image
```

The `main` branch should be protected.

Recommended branch protection:

-   Pull request required
-   CI checks required
-   No direct push
-   At least one review if possible

------------------------------------------------------------------------

# 9. CI Pipeline

Use GitHub Actions.

Pipeline stages:

``` text
Checkout
   ↓
Setup Runtime
   ↓
Install Dependencies
   ↓
Lint
   ↓
Unit Tests
   ↓
SAST
   ↓
Secret Scan
   ↓
Dependency Scan
   ↓
Docker Build
   ↓
Image Scan
   ↓
SBOM
   ↓
Push Image
   ↓
Update GitOps Repository
```

Separate pull-request validation from production release where useful.

------------------------------------------------------------------------

# 10. Unit Testing

Before security and deployment:

``` text
npm test
```

The pipeline must fail if tests fail.

Demonstrate:

``` text
Code Change
    ↓
Broken Test
    ↓
CI FAILURE
    ↓
No Deployment
```

This establishes the first quality gate.

------------------------------------------------------------------------

# 11. SonarQube --- SAST

Use SonarQube for static application analysis.

Topics to understand:

-   SAST
-   Code smells
-   Bugs
-   Vulnerabilities
-   Security hotspots
-   Quality Gate
-   Code coverage

Pipeline concept:

``` text
Source Code
    ↓
SonarQube
    ↓
Quality Gate
    ├── PASS → Continue
    └── FAIL → Stop
```

Do not merely run SonarQube. Configure a meaningful Quality Gate.

------------------------------------------------------------------------

# 12. Gitleaks --- Secret Scanning

Use Gitleaks to detect secrets in source code.

Examples of things it should detect:

``` text
AWS access keys
API tokens
Passwords
Private keys
Database credentials
```

Pipeline:

``` text
Git Repository
      ↓
Gitleaks
      ↓
Secret Found?
   ┌──┴──┐
  YES    NO
   ↓      ↓
 FAIL   Continue
```

Important rule:

Never put real credentials into Git.

Use GitHub Secrets / AWS IAM / workload identity mechanisms instead.

------------------------------------------------------------------------

# 13. Dependency Scanning

Use Trivy or another approved scanner to scan application dependencies.

The goal is to identify:

-   Known CVEs
-   Vulnerable libraries
-   Risky package versions

The pipeline should define a policy for what severity blocks the build.

Example:

``` text
CRITICAL → Block
HIGH     → Block
MEDIUM   → Report
LOW      → Report
```

The exact policy can be adjusted depending on the application and
scanner output.

------------------------------------------------------------------------

# 14. Container Image Scanning

This is a major DevSecOps component.

Build:

``` text
secureship:<git-sha>
```

Then scan:

``` text
Trivy
   ↓
Docker Image
   ↓
CVE Database
```

Example policy:

``` text
CRITICAL vulnerabilities → FAIL
HIGH vulnerabilities      → FAIL
MEDIUM                    → Report
LOW                       → Report
```

The pipeline must prevent vulnerable images from being published.

Important concept:

``` text
Build Image
     ↓
Scan Image
     ↓
PASS ─────→ ECR
FAIL ─────→ Stop Pipeline
```

Do not scan after deployment and call it a security gate. The scan must
happen before production publication/deployment.

------------------------------------------------------------------------

# 15. SBOM

Use Syft to generate a Software Bill of Materials.

The SBOM should describe:

-   Application dependencies
-   OS packages
-   Libraries
-   Versions

Generate an artifact such as:

``` text
sbom.json
```

Store it as a GitHub Actions artifact and/or associate it with the image
release.

Understand:

-   What is an SBOM?
-   Why software supply-chain visibility matters
-   SPDX
-   CycloneDX
-   Dependency provenance

------------------------------------------------------------------------

# 16. Image Tagging

Avoid relying on:

``` text
latest
```

Use immutable identifiers.

Recommended:

``` text
secureship:<git-commit-sha>
```

Example:

``` text
secureship:91ac442
```

The image should be traceable to:

``` text
Git commit
    ↓
CI run
    ↓
Docker image
    ↓
ECR
    ↓
Kubernetes deployment
```

For advanced implementation, use the immutable image digest.

------------------------------------------------------------------------

# 17. AWS ECR

Create an ECR repository.

Flow:

``` text
GitHub Actions
      ↓
Docker Build
      ↓
Trivy Scan
      ↓
ECR Login
      ↓
Docker Push
```

Topics:

-   ECR repositories
-   Image tags
-   Image digests
-   IAM
-   Registry authentication
-   Image lifecycle policies

Configure an ECR lifecycle policy to prevent unlimited old images from
accumulating.

------------------------------------------------------------------------

# 18. Kubernetes

Deploy the application to Kubernetes.

Core resources:

``` text
Namespace
Deployment
Service
ConfigMap
Secret
ServiceAccount
Ingress
HorizontalPodAutoscaler
NetworkPolicy
```

Understand:

-   Pod
-   ReplicaSet
-   Deployment
-   Service
-   Ingress
-   Namespace
-   ConfigMap
-   Secret
-   ServiceAccount
-   Scheduler
-   Controller
-   Control plane
-   Worker node

------------------------------------------------------------------------

# 19. Kubernetes Deployment

The Deployment should define:

-   Replica count
-   Container image
-   Resource requests
-   Resource limits
-   Liveness probe
-   Readiness probe
-   Security context
-   Service account

Example desired behavior:

``` text
replicas: 2
```

If one pod fails:

``` text
2 Pods
 ↓
1 Pod crashes
 ↓
Kubernetes replaces it
 ↓
2 healthy Pods
```

------------------------------------------------------------------------

# 20. Kubernetes Security Context

The container should not run as root.

Configure:

``` text
runAsNonRoot: true
allowPrivilegeEscalation: false
readOnlyRootFilesystem: true (where compatible)
```

Drop unnecessary Linux capabilities.

The goal is to demonstrate container hardening.

------------------------------------------------------------------------

# 21. Kubernetes RBAC

Create a dedicated ServiceAccount for the application.

Do not give the application:

``` text
cluster-admin
```

unless there is an exceptional reason.

Understand:

``` text
User
 ↓
Role / ClusterRole
 ↓
RoleBinding / ClusterRoleBinding
 ↓
Permission
```

Use least privilege.

------------------------------------------------------------------------

# 22. NetworkPolicy

Implement network segmentation.

Example:

``` text
Internet
   ↓
Ingress
   ↓
Backend
   ↓
Database
```

The backend should be allowed to communicate with PostgreSQL.

Other unnecessary communication should be blocked.

Concept:

``` text
Default Deny
    ↓
Explicitly Allow Required Traffic
```

This demonstrates Kubernetes network security.

------------------------------------------------------------------------

# 23. Helm

Package the Kubernetes application using Helm.

Chart:

``` text
charts/secureship/
```

Use configurable values for:

-   Image repository
-   Image tag
-   Replica count
-   CPU
-   Memory
-   Service type
-   Ingress
-   Environment
-   HPA
-   Resources

Do not duplicate complete manifests for every environment.

------------------------------------------------------------------------

# 24. GitOps

This is a critical part of the project.

The GitOps repository contains the desired state.

Example:

``` yaml
image:
  repository: <ECR_REPOSITORY>
  tag: 91ac442
```

When CI creates a new image:

``` text
Image 91ac442
      ↓
CI updates GitOps repo
      ↓
tag becomes 91ac442
      ↓
Git commit
```

Argo CD detects the change.

------------------------------------------------------------------------

# 25. Argo CD

Argo CD continuously compares:

``` text
Git Desired State
        VS
Kubernetes Live State
```

If they differ:

``` text
OutOfSync
```

Argo CD can reconcile the cluster to Git.

Flow:

``` text
GitOps Repository
       ↓
     Argo CD
       ↓
   Kubernetes
```

Important topics:

-   Application
-   Project
-   Sync
-   Auto-sync
-   Health
-   Drift detection
-   Rollback
-   Reconciliation

------------------------------------------------------------------------

# 26. GitOps Deployment Rule

Do not make the GitHub Actions deployment stage run:

``` bash
kubectl apply
```

The preferred architecture is:

``` text
CI
 ↓
Build + Security
 ↓
Push Image
 ↓
Update GitOps Repository
 ↓
Argo CD
 ↓
Kubernetes
```

This provides:

-   Auditability
-   Reproducibility
-   Git-based desired state
-   Easier rollback
-   Separation of CI and CD

------------------------------------------------------------------------

# 27. Environment Strategy

Create:

``` text
dev
prod
```

Example:

``` text
environments/
├── dev/
│   └── values.yaml
└── prod/
    └── values.yaml
```

Development can have:

``` text
replicas: 1
```

Production:

``` text
replicas: 2 or more
```

Production should also have stricter resource/security settings.

------------------------------------------------------------------------

# 28. Kyverno

Kyverno is a Kubernetes policy engine.

Use it to enforce rules at admission time.

Required policies:

## Policy 1 --- No privileged containers

Reject:

``` text
privileged: true
```

## Policy 2 --- Require non-root

Reject workloads that do not enforce non-root execution.

## Policy 3 --- Require resource limits

Require:

``` text
resources:
  requests:
  limits:
```

## Policy 4 --- Require approved image registry

Only allow images from:

``` text
AWS ECR
```

or another approved registry.

This creates a strong security story:

``` text
Developer submits workload
        ↓
Kubernetes Admission
        ↓
Kyverno
        ↓
Policy Validation
        ↓
ALLOW / DENY
```

------------------------------------------------------------------------

# 29. Terraform

Provision AWS infrastructure using Terraform.

Suggested structure:

``` text
terraform/
├── main.tf
├── variables.tf
├── outputs.tf
├── providers.tf
├── versions.tf
├── vpc.tf
├── eks.tf
├── ecr.tf
├── iam.tf
└── terraform.tfvars.example
```

Provision:

-   VPC
-   Subnets
-   Internet/NAT components as required
-   Security groups
-   IAM
-   ECR
-   EKS

Do not commit:

``` text
terraform.tfvars
```

if it contains secrets.

Also understand Terraform state and state locking.

------------------------------------------------------------------------

# 30. AWS EKS

Use EKS for the production-style Kubernetes environment.

Understand:

-   EKS control plane
-   Worker nodes
-   Node groups
-   IAM
-   VPC networking
-   Security groups
-   Kubernetes API access
-   EKS add-ons

Do not blindly use a large expensive cluster.

For a portfolio project, minimize cost.

------------------------------------------------------------------------

# 31. HPA

Implement Horizontal Pod Autoscaler.

Example:

``` text
CPU > threshold
     ↓
HPA
     ↓
Increase replicas
```

Example:

``` text
2 replicas
   ↓
CPU increases
   ↓
4 replicas
```

Understand:

-   CPU utilization
-   Memory utilization
-   Metrics Server
-   minReplicas
-   maxReplicas
-   scaling behavior

------------------------------------------------------------------------

# 32. Prometheus

Use Prometheus to collect metrics.

Monitor:

-   CPU
-   Memory
-   Pod count
-   Pod restarts
-   Request count
-   Request latency
-   Error rate
-   Kubernetes node health

Understand:

-   Metrics
-   Scraping
-   Targets
-   PromQL
-   Exporters

------------------------------------------------------------------------

# 33. Grafana

Create dashboards.

Minimum dashboards:

## Kubernetes Dashboard

Show:

-   Nodes
-   Pods
-   CPU
-   Memory
-   Restarts
-   Replica availability

## Application Dashboard

Show:

-   Requests
-   Error rate
-   Latency
-   Throughput

Do not create dashboards only for screenshots. Make the metrics actually
useful.

------------------------------------------------------------------------

# 34. Loki

Use Loki for centralized logs.

Flow:

``` text
Application
    ↓
Log Collector
    ↓
Loki
    ↓
Grafana
```

Be able to search:

``` text
ERROR
WARN
request-id
pod-name
service
```

Understand the difference between:

``` text
Metrics
Logs
Traces
```

Tracing is optional for this project.

------------------------------------------------------------------------

# 35. Alerting

Create at least a few alerts.

Examples:

``` text
Pod CrashLooping
High CPU
High Memory
Application Error Rate
Pod unavailable
Deployment replicas unavailable
```

Example:

``` text
Error rate > threshold
        ↓
Prometheus Alert
        ↓
Alertmanager
        ↓
Notification
```

The notification destination can be Slack, email, Discord, or another
suitable channel.

------------------------------------------------------------------------

# 36. Security Gates

The final pipeline should contain explicit gates.

``` text
                  CI
                   │
        ┌──────────┼──────────┐
        ▼          ▼          ▼
      Tests     SonarQube   Gitleaks
        │          │          │
        └──────────┼──────────┘
                   ▼
             Dependency Scan
                   │
                   ▼
              Docker Build
                   │
                   ▼
              Trivy Scan
                   │
             ┌─────┴─────┐
             │           │
           FAIL         PASS
             │           │
             ▼           ▼
           STOP         SBOM
                         │
                         ▼
                        ECR
```

The important point is that security tools influence the deployment
decision.

------------------------------------------------------------------------

# 37. Rollback

Demonstrate a rollback.

Example:

``` text
Production
   ↓
Version A
```

Deploy:

``` text
Version B
```

If Version B is broken:

``` text
GitOps
   ↓
Revert commit
   ↓
Argo CD
   ↓
Version A
```

This is one of the most valuable GitOps demonstrations.

------------------------------------------------------------------------

# 38. Failure Scenarios to Demonstrate

The project should intentionally test failures.

## Failure 1 --- Unit test fails

Expected:

``` text
Pipeline FAILS
Deployment does not happen
```

## Failure 2 --- Secret committed

Expected:

``` text
Gitleaks detects secret
Pipeline FAILS
```

## Failure 3 --- Vulnerable dependency

Expected:

``` text
Dependency scanner detects CVE
Pipeline FAILS
```

## Failure 4 --- Vulnerable Docker image

Expected:

``` text
Trivy detects HIGH/CRITICAL CVE
Image publication blocked
```

## Failure 5 --- Kyverno violation

Attempt:

``` text
privileged: true
```

Expected:

``` text
Kubernetes admission DENIES workload
```

## Failure 6 --- Application crash

Expected:

``` text
Kubernetes restarts pod
Prometheus records restart
Grafana shows problem
```

## Failure 7 --- GitOps drift

Manually change a Kubernetes resource.

Expected:

``` text
Argo CD detects drift
```

Depending on sync configuration:

``` text
Argo CD reconciles desired Git state
```

------------------------------------------------------------------------

# 39. Observability Demo

A strong demo sequence:

``` text
Deploy application
       ↓
Open Grafana
       ↓
Generate traffic
       ↓
Observe request metrics
       ↓
Introduce application error
       ↓
Observe error-rate increase
       ↓
Check Loki logs
       ↓
Fix application
       ↓
Observe recovery
```

This makes the project feel like an actual operational platform.

------------------------------------------------------------------------

# 40. Project Folder Structure

Recommended final structure:

``` text
secureship/
│
├── app/
│   ├── src/
│   ├── tests/
│   ├── package.json
│   ├── Dockerfile
│   └── .dockerignore
│
├── .github/
│   └── workflows/
│       ├── pull-request.yml
│       └── release.yml
│
├── terraform/
│   ├── providers.tf
│   ├── versions.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── vpc.tf
│   ├── eks.tf
│   ├── ecr.tf
│   └── iam.tf
│
├── helm/
│   └── secureship/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│
├── kyverno/
│   ├── require-non-root.yaml
│   ├── require-resource-limits.yaml
│   ├── disallow-privileged.yaml
│   └── allowed-registry.yaml
│
├── monitoring/
│   ├── prometheus/
│   ├── grafana/
│   └── loki/
│
├── argocd/
│   ├── application-dev.yaml
│   └── application-prod.yaml
│
└── README.md
```

In the real implementation, keep the application repository and GitOps
repository separate. This structure is a conceptual workspace layout.

------------------------------------------------------------------------

# 41. CI/CD Pipeline Design

## Pull Request Pipeline

Runs on:

``` text
pull_request
```

Stages:

``` text
Checkout
 ↓
Install
 ↓
Lint
 ↓
Unit Tests
 ↓
SonarQube
 ↓
Gitleaks
 ↓
Dependency Scan
```

It should not publish a production image.

## Main Branch Pipeline

Runs after merge:

``` text
Checkout
 ↓
Tests
 ↓
Security
 ↓
Docker Build
 ↓
Trivy
 ↓
SBOM
 ↓
Push ECR
 ↓
Update GitOps
```

------------------------------------------------------------------------

# 42. GitOps Update Mechanism

After a successful image build:

``` text
IMAGE_TAG = Git SHA
```

Update:

``` yaml
image:
  tag: <Git SHA>
```

Commit to GitOps repository:

``` text
chore: deploy image <sha>
```

Then:

``` text
GitOps commit
      ↓
Argo CD detects change
      ↓
Kubernetes deployment
```

Use a secure GitHub token or GitHub App mechanism for repository
updates.

Do not hard-code tokens.

------------------------------------------------------------------------

# 43. Secrets Management

Never store:

``` text
AWS_ACCESS_KEY
AWS_SECRET_ACCESS_KEY
DATABASE_PASSWORD
API_KEY
```

in Git.

Use appropriate mechanisms such as:

-   GitHub Secrets
-   AWS IAM
-   Kubernetes Secrets
-   External Secrets Operator as an optional advanced improvement
-   AWS Secrets Manager as an optional advanced improvement

For the first version, keep secret management simple and secure.

------------------------------------------------------------------------

# 44. Security Principles

The project should follow:

## Least Privilege

Every identity gets only the permissions it requires.

## Defense in Depth

Security exists at multiple layers:

``` text
Source Code
   ↓
Dependencies
   ↓
Docker Image
   ↓
Kubernetes
   ↓
Network
   ↓
Runtime
```

## Shift Left

Find problems before production.

``` text
Developer
   ↓
CI Security
   ↓
Registry
   ↓
Cluster Admission
   ↓
Runtime Monitoring
```

## Immutable Releases

Deploy specific image versions/digests rather than mutable `latest`.

------------------------------------------------------------------------

# 45. Cost Control

AWS costs matter.

For a portfolio project:

-   Use the smallest practical EKS setup.
-   Destroy infrastructure when not using it.
-   Avoid unnecessary NAT gateways where architecture permits.
-   Keep ECR lifecycle policies.
-   Avoid oversized worker nodes.
-   Do not leave development clusters running permanently.

Use:

``` bash
terraform destroy
```

when the environment is no longer needed.

Never blindly destroy production resources.

------------------------------------------------------------------------

# 46. Implementation Roadmap

## Phase 1 --- Application + Docker

Estimated: 2--3 hours

Tasks:

-   Create Express application
-   Add health endpoints
-   Add tests
-   Create Dockerfile
-   Build image
-   Run locally

Deliverable:

``` text
Application runs inside Docker
```

------------------------------------------------------------------------

## Phase 2 --- CI

Estimated: 2--3 hours

Tasks:

-   GitHub Actions
-   Lint
-   Unit tests
-   Pull request checks
-   Branch protection

Deliverable:

``` text
Git push → automated CI
```

------------------------------------------------------------------------

## Phase 3 --- DevSecOps

Estimated: 4--6 hours

Tasks:

-   SonarQube
-   Gitleaks
-   Dependency scanning
-   Trivy
-   Security thresholds
-   SBOM

Deliverable:

``` text
Insecure code/image → pipeline blocked
```

------------------------------------------------------------------------

## Phase 4 --- ECR

Estimated: 1--2 hours

Tasks:

-   Create ECR
-   Configure authentication
-   Push immutable image
-   Configure lifecycle policy

Deliverable:

``` text
Secure image → ECR
```

------------------------------------------------------------------------

## Phase 5 --- Kubernetes + Helm

Estimated: 3--5 hours

Tasks:

-   Kubernetes deployment
-   Service
-   Ingress
-   ConfigMap
-   Secret
-   Probes
-   Resource limits
-   Security context
-   Helm chart

Deliverable:

``` text
Application running on Kubernetes
```

------------------------------------------------------------------------

## Phase 6 --- GitOps

Estimated: 2--4 hours

Tasks:

-   Create GitOps repo
-   Configure Helm values
-   Install Argo CD
-   Configure Application
-   Enable synchronization
-   Test rollback

Deliverable:

``` text
Git change → Argo CD → Kubernetes
```

------------------------------------------------------------------------

## Phase 7 --- Terraform + AWS

Estimated: 4--6 hours

Tasks:

-   VPC
-   IAM
-   ECR
-   EKS
-   Node group
-   Outputs
-   Variables
-   State management

Deliverable:

``` text
AWS infrastructure reproducible using Terraform
```

------------------------------------------------------------------------

## Phase 8 --- Kubernetes Security

Estimated: 2--4 hours

Tasks:

-   RBAC
-   ServiceAccount
-   NetworkPolicy
-   Kyverno
-   Non-root policy
-   Resource policy
-   Approved registry policy

Deliverable:

``` text
Unsafe workload → admission denied
```

------------------------------------------------------------------------

## Phase 9 --- Observability

Estimated: 3--5 hours

Tasks:

-   Prometheus
-   Grafana
-   Loki
-   Dashboards
-   Alerts
-   Failure testing

Deliverable:

``` text
Application + cluster are observable
```

------------------------------------------------------------------------

## Phase 10 --- Documentation + Demo

Estimated: 2--3 hours

Create:

-   Architecture diagram
-   README
-   CI screenshot
-   Trivy screenshot
-   Argo CD screenshot
-   Kubernetes screenshot
-   Grafana dashboard
-   Kyverno rejection example
-   Rollback demonstration

------------------------------------------------------------------------

# 47. Expected Total Time

Approximate:

``` text
Phase 1        2–3 h
Phase 2        2–3 h
Phase 3        4–6 h
Phase 4        1–2 h
Phase 5        3–5 h
Phase 6        2–4 h
Phase 7        4–6 h
Phase 8        2–4 h
Phase 9        3–5 h
Phase 10       2–3 h
---------------------
TOTAL          25–41 h
```

If learning while building:

``` text
35–50 hours
```

Do not rush. Understanding the architecture is more important than
finishing quickly.

------------------------------------------------------------------------

# 48. MVP vs Full Version

## MVP

Build first:

``` text
GitHub
 ↓
GitHub Actions
 ↓
Tests
 ↓
Trivy
 ↓
Docker
 ↓
ECR
 ↓
Kubernetes
```

Estimated:

``` text
8–12 hours
```

## Resume Version

Add:

``` text
SonarQube
Gitleaks
SBOM
Helm
Argo CD
GitOps
```

Estimated total:

``` text
16–25 hours
```

## Production-Style Version

Add:

``` text
Terraform
EKS
Kyverno
RBAC
NetworkPolicy
HPA
Prometheus
Grafana
Loki
Alerts
Rollback
```

Estimated total:

``` text
25–41 hours
```

------------------------------------------------------------------------

# 49. AI Agent Instructions

If an AI coding agent is used to build this project, it must follow
these rules.

## Rule 1 --- Understand Before Modifying

Before changing files:

1.  Inspect the repository.
2.  Identify existing architecture.
3.  Identify dependencies.
4.  Identify current CI/CD.
5.  Identify current Docker configuration.
6.  Explain the proposed change.
7.  Then implement it.

Do not blindly overwrite files.

## Rule 2 --- Work Incrementally

Implement one phase at a time.

Order:

``` text
Application
→ Docker
→ CI
→ DevSecOps
→ Registry
→ Kubernetes
→ Helm
→ GitOps
→ Argo CD
→ Terraform
→ Security Policies
→ Observability
```

## Rule 3 --- Validate Every Phase

After each implementation:

-   Run tests.
-   Build the application.
-   Build the Docker image.
-   Validate YAML.
-   Validate Helm.
-   Validate Terraform.
-   Validate Kubernetes manifests.
-   Check logs.
-   Document errors and fixes.

## Rule 4 --- Never Fake Infrastructure

Do not create documentation claiming:

``` text
EKS deployed
Argo CD working
Trivy passed
Grafana monitoring
```

unless it has actually been tested.

## Rule 5 --- Never Commit Secrets

Never create fake files containing realistic credentials that could be
mistaken for real credentials.

Use:

``` text
.env.example
terraform.tfvars.example
```

with placeholders.

## Rule 6 --- Prefer Secure Defaults

Containers should:

-   Run as non-root.
-   Drop unnecessary privileges.
-   Avoid privileged mode.
-   Use resource limits.
-   Use health checks.
-   Use least-privilege RBAC.
-   Use immutable image tags.
-   Avoid plaintext credentials.

## Rule 7 --- Do Not Use `latest`

Use Git SHA or immutable image digest.

## Rule 8 --- GitOps Must Remain GitOps

Do not bypass Argo CD with:

``` bash
kubectl apply
```

for normal production deployments.

The desired state must be stored in Git.

## Rule 9 --- Security Gates Must Actually Gate

A security scanner that only prints warnings is not sufficient.

Where policy requires blocking:

``` text
Security failure → CI failure → no release
```

## Rule 10 --- Keep Documentation Updated

Every major implementation must update:

-   README
-   Architecture
-   Setup instructions
-   Troubleshooting
-   Security model
-   Deployment process

------------------------------------------------------------------------

# 50. AI Agent Phase Prompt

Use this as the master instruction for an AI coding agent:

``` text
You are the implementation agent for the SecureShip project.

Build a production-style DevSecOps and GitOps platform.

The final architecture is:

Developer
→ GitHub
→ GitHub Actions
→ Tests
→ SonarQube
→ Gitleaks
→ Dependency Scan
→ Docker Build
→ Trivy Image Scan
→ SBOM
→ AWS ECR
→ GitOps Repository
→ Argo CD
→ AWS EKS
→ Kyverno
→ Kubernetes
→ Prometheus
→ Grafana
→ Loki

Use:
- Node.js + Express
- Docker
- GitHub Actions
- AWS ECR
- AWS EKS
- Kubernetes
- Helm
- Argo CD
- Terraform
- SonarQube
- Gitleaks
- Trivy
- Syft
- Kyverno
- Prometheus
- Grafana
- Loki

Use two repositories:
1. Application repository
2. GitOps repository

Do not mix GitOps deployment state with application source code unnecessarily.

Implement the project incrementally.

Phase 1:
Build the application and tests.

Phase 2:
Containerize the application.

Phase 3:
Create GitHub Actions CI.

Phase 4:
Add SonarQube, Gitleaks, dependency scanning, Trivy and SBOM.

Phase 5:
Create AWS ECR integration.

Phase 6:
Create Helm-based Kubernetes deployment.

Phase 7:
Create GitOps repository and Argo CD deployment.

Phase 8:
Provision AWS infrastructure using Terraform.

Phase 9:
Implement Kubernetes security using RBAC, NetworkPolicy and Kyverno.

Phase 10:
Implement Prometheus, Grafana, Loki and alerts.

At every phase:
- Inspect existing files first.
- Do not blindly overwrite files.
- Explain what you are changing.
- Implement only the current phase.
- Validate the implementation.
- Fix errors before moving forward.
- Update documentation.
- Never hard-code secrets.
- Never use production credentials.
- Never use the mutable "latest" image tag for deployment.
- Use Git SHA or image digest.
- Do not bypass Argo CD with kubectl for normal GitOps deployments.
- Security failures must block releases when configured as blocking policies.
- Never claim a component is working unless it has been tested.

The project must be understandable to a DevOps interviewer.

For every major technology, document:
1. What it is.
2. Why it is used.
3. Where it appears in the architecture.
4. How it works in this project.
5. How to configure it.
6. How to test it.
7. Common failure modes.
8. How to troubleshoot it.
9. Why this technology was selected over alternatives.

Prioritize correctness, security, reproducibility and learning value over speed.
```

------------------------------------------------------------------------

# 51. Interview Topics to Prepare

The project should allow you to answer these questions.

## Git

-   Git branching
-   Merge vs rebase
-   Pull requests
-   Branch protection
-   Git tags
-   Commit SHA

## CI/CD

-   What is CI?
-   What is CD?
-   Why GitHub Actions?
-   Pipeline stages
-   Artifacts
-   Secrets
-   Runners
-   Failure handling

## Docker

-   Image vs container
-   Docker layers
-   Multi-stage builds
-   Container networking
-   Docker security
-   Non-root containers

## DevSecOps

-   DevOps vs DevSecOps
-   Shift-left security
-   Security gates
-   SAST
-   Dependency scanning
-   Secret scanning
-   Container scanning
-   SBOM

## Trivy

-   What does Trivy scan?
-   What is CVE?
-   HIGH vs CRITICAL
-   Why scan before deployment?
-   How does the pipeline block vulnerable images?

## Kubernetes

-   Pod
-   Deployment
-   Service
-   Ingress
-   ConfigMap
-   Secret
-   HPA
-   Namespace
-   ServiceAccount
-   RBAC

## Helm

-   Chart
-   Values
-   Templates
-   Release
-   Why Helm instead of raw YAML?

## GitOps

-   What is GitOps?
-   Why Git is the source of truth?
-   Why two repositories?
-   How does rollback work?
-   What is drift?

## Argo CD

-   What is reconciliation?
-   What is OutOfSync?
-   Auto-sync
-   Health
-   Rollback
-   Desired state vs live state

## Terraform

-   IaC
-   State
-   Plan
-   Apply
-   Destroy
-   Modules
-   Variables
-   Outputs
-   State locking

## AWS

-   VPC
-   Subnets
-   Security groups
-   IAM
-   ECR
-   EKS
-   Node groups

## Kubernetes Security

-   Least privilege
-   RBAC
-   NetworkPolicy
-   SecurityContext
-   Kyverno
-   Admission control
-   Non-root containers
-   Privileged containers

## Observability

-   Metrics vs logs
-   Prometheus
-   PromQL
-   Grafana
-   Loki
-   Alerts
-   SLI/SLO basics

------------------------------------------------------------------------

# 52. Final Resume Outcome

The project should ultimately be described approximately as:

**SecureShip --- End-to-End DevSecOps & GitOps Platform**

-   Built an end-to-end DevSecOps pipeline using GitHub Actions with
    automated testing, SonarQube SAST, Gitleaks secret scanning,
    dependency analysis, Trivy container scanning and SBOM generation.
-   Containerized and deployed a Node.js application to AWS EKS using
    Docker, Helm and Argo CD, implementing GitOps-based continuous
    delivery with Git as the source of truth.
-   Provisioned AWS infrastructure using Terraform and implemented
    Kubernetes security controls including Kyverno admission policies,
    RBAC, NetworkPolicies, non-root containers and resource governance.
-   Implemented Prometheus, Grafana and Loki for Kubernetes/application
    observability, including dashboards, logs, health monitoring and
    alerts.
-   Designed security gates and rollback workflows to prevent vulnerable
    container images and non-compliant Kubernetes workloads from
    reaching production.

------------------------------------------------------------------------

# 53. Definition of Done

The project is complete only when all of these work:

-   [ ] Application runs locally
-   [ ] Unit tests pass
-   [ ] Docker image builds
-   [ ] Container runs as non-root
-   [ ] GitHub Actions CI works
-   [ ] SonarQube scan works
-   [ ] Gitleaks works
-   [ ] Dependency scan works
-   [ ] Trivy image scan works
-   [ ] Vulnerable image blocks release
-   [ ] SBOM is generated
-   [ ] ECR receives approved images
-   [ ] Kubernetes cluster works
-   [ ] Helm deployment works
-   [ ] Health probes work
-   [ ] HPA works
-   [ ] RBAC works
-   [ ] NetworkPolicy works
-   [ ] Kyverno blocks invalid workloads
-   [ ] GitOps repository works
-   [ ] Argo CD sync works
-   [ ] Git change deploys automatically
-   [ ] Rollback works
-   [ ] Terraform provisions infrastructure
-   [ ] Prometheus collects metrics
-   [ ] Grafana dashboard works
-   [ ] Loki collects/searches logs
-   [ ] Alerts work
-   [ ] Documentation is complete
-   [ ] Architecture diagram is included
-   [ ] Failure scenarios are demonstrated

------------------------------------------------------------------------

# 54. Final Project Philosophy

Do not build this project simply to list technologies.

Build it to demonstrate this engineering lifecycle:

``` text
WRITE CODE
    ↓
TEST CODE
    ↓
SECURE CODE
    ↓
BUILD IMAGE
    ↓
SCAN IMAGE
    ↓
PUBLISH IMMUTABLE IMAGE
    ↓
UPDATE DESIRED STATE IN GIT
    ↓
GITOPS DEPLOYMENT
    ↓
KUBERNETES SECURITY
    ↓
MONITOR
    ↓
DETECT FAILURE
    ↓
ROLL BACK / FIX
```

If all of these pieces work together, SecureShip becomes a strong
flagship DevOps/DevSecOps portfolio project rather than a tutorial
collection.

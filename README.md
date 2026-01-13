# Internal Developer Platform (IDP)

Overview

This repository contains a production-grade Internal Developer Platform (IDP) designed to improve developer velocity while enforcing security, reliability, and operational standards by default.

The platform enables self-service provisioning, GitOps-based delivery, and policy-driven governance across multiple Kubernetes environments.

## 🎯 Objectives

- Reduce service onboarding time from days to minutes
- Enforce security and compliance without blocking teams
- Standardize infrastructure and deployment patterns
- Improve reliability through GitOps and automation

## 🧱 Platform Architecture

### Core Components

- **Backstage** – Developer self-service portal
- **Terraform** – Reusable infrastructure modules
- **GitHub Actions** – CI, security, and validation
- **ArgoCD** – GitOps continuous delivery
- **EKS** – Kubernetes runtime
- **OPA Gatekeeper** – Policy enforcement
- **AWS Secrets Manager** – Secure secrets handling
- **Multi-Cluster Environments** – Dev / Staging / Prod

## 🔁 Developer Workflow

1. Developer logs into Backstage via SSO
2. Selects a golden path (service template)
3. Backstage scaffolds repo + CI + infra
4. GitHub Actions validates and scans
5. ArgoCD deploys via GitOps
6. Policies, secrets, and budgets applied automatically

## 🔐 Security & Governance

- OIDC SSO (Okta / Azure AD)
- RBAC tied to Backstage entities
- IRSA for AWS access
- Policy-as-Code using OPA
- No direct cluster access

## 💰 Cost Management

- Namespace budgets
- Cost allocation by service/team
- Chargeback / showback reporting

## 📈 Reliability & Operations

- Multi-environment isolation
- Automated rollbacks
- Platform SLOs
- Incident runbooks

## 🧠 Why This Matters

This platform treats infrastructure as a product, not a ticket queue — enabling teams to ship faster while reducing operational risk.

## 📁 Project Structure

```
internal-developer-platform/
├── .github/
│   └── workflows/
│       ├── app-ci.yaml
│       ├── security.yaml
│       └── terraform.yaml
├── backstage/
│   ├── app-config.yaml
│   ├── catalog-info.yaml
│   ├── techdocs/
│   └── templates/
├── terraform/
│   ├── modules/
│   └── environments/
├── gitops/
│   └── argocd/
├── policies/
│   └── opa/
├── scripts/
└── docs/
```

# Getting Started with the Internal Developer Platform

This guide will help you get started with the Internal Developer Platform (IDP) and begin using its self-service capabilities.

## 🎯 Overview

The IDP provides a complete developer experience that allows you to:

- Create new services from standardized templates
- Deploy applications using GitOps workflows
- Access shared infrastructure components
- Monitor your services

## 🚀 Creating Your First Service

### 1. Access Backstage

Navigate to the Backstage portal and authenticate with your corporate credentials.

### 2. Choose a Template

From the Backstage homepage, select "Create..." from the left navigation menu. You'll see several golden path templates:

- **Backend Service**: For creating API services
- **Worker Service**: For background processing services
- **Infra-only**: For infrastructure-only components

### 3. Fill in Service Details

Provide the required information for your service:

- Service name
- Description
- Owner (team or individual)
- Repository location

### 4. Review and Create

Review the information and click "Create" to generate your new service repository.

## 📦 What You Get

When you create a service using the IDP templates, you automatically get:

### Repository Structure
```
your-service/
├── README.md
├── Dockerfile
├── .github/
│   └── workflows/
│       └── ci.yaml
├── k8s/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── ingress.yaml
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── catalog-info.yaml
└── src/
    └── (your application code)
```

### Pre-configured Components

- **CI Pipeline**: GitHub Actions workflow for testing and building
- **Kubernetes Manifests**: Deploy-ready configurations
- **Terraform Code**: Infrastructure as Code templates
- **Service Catalog Entry**: Automatically registered in Backstage
- **GitOps Configuration**: Ready for ArgoCD deployment

## 🚢 Deploying Your Service

### 1. Code Changes

Make your application changes in the `src/` directory and commit to your repository.

### 2. Pull Request Process

- Create a pull request to the main branch
- Automated checks will run (linting, tests, security scans)
- Once approved, your code will be merged

### 3. Automated Deployment

- GitHub Actions builds and pushes your container image
- ArgoCD automatically deploys the new version
- Your service is updated with zero downtime

## 🔧 Managing Your Service

### In Backstage

- View your service in the Service Catalog
- Access documentation and API definitions
- Monitor deployment status
- Access related resources

### In GitHub

- Track issues and pull requests
- Review code changes and history
- Collaborate with team members

## 📊 Monitoring and Observability

Your service is automatically integrated with the platform's monitoring stack:

- **Logging**: Centralized log aggregation
- **Metrics**: Performance and business metrics
- **Alerting**: Automated alerting based on SLOs
- **Tracing**: Distributed tracing for debugging

## 🤝 Need Help?

- Check the [FAQ](../faq/index.md)
- Join the #platform-users Slack channel
- Create an issue in the platform's repository
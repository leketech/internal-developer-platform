# Internal Developer Platform Documentation

Welcome to the Internal Developer Platform (IDP) documentation. This platform is designed to improve developer velocity while enforcing security, reliability, and operational standards by default.

## 🚀 Getting Started

The IDP provides a self-service portal for developers to:

- Scaffold new services using standardized templates
- Deploy applications using GitOps
- Access shared infrastructure components
- Monitor service health and performance

### Prerequisites

Before using the platform, ensure you have:

- Access to the Backstage portal
- GitHub account linked to the platform
- Appropriate permissions for your team

## 🏗️ Platform Architecture

The platform consists of several key components:

- **Backstage**: Developer self-service portal
- **Terraform**: Infrastructure as Code management
- **GitHub Actions**: CI/CD workflows and validation
- **ArgoCD**: GitOps continuous delivery
- **EKS**: Kubernetes runtime
- **OPA/Gatekeeper**: Policy enforcement

## 📚 Navigation

- [Getting Started Guide](getting-started/index.md)
- [Service Templates](templates/index.md)
- [Deployment Process](deployment/index.md)
- [Troubleshooting](troubleshooting/index.md)
- [Security Guidelines](security/index.md)

## 🤝 Support

If you need assistance, please:

- Check the [FAQ](faq/index.md) section
- Contact the platform team via Slack: #platform-support
- Create a ticket in our [Jira project](https://your-company.atlassian.net)
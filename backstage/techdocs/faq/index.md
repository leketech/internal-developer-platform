# Frequently Asked Questions

This FAQ addresses common questions about the Internal Developer Platform.

## Platform Basics

### What is the Internal Developer Platform?
The Internal Developer Platform (IDP) is a self-service platform that accelerates development while enforcing security, reliability, and operational standards. It provides standardized tools and processes for building, deploying, and managing applications.

### Who can use the platform?
Any developer in the organization with appropriate permissions can use the platform. Contact your team lead or the platform team to get access.

### How do I get access to the platform?
Access is typically granted through your GitHub account and corporate SSO. If you don't have access, contact the platform team via #platform-support channel.

## Service Creation

### How do I create a new service?
1. Navigate to the Backstage portal
2. Click "Create..." in the left navigation
3. Select a template that fits your needs
4. Fill in the required information
5. Create your service

### What templates are available?
- Backend Service: For HTTP APIs and microservices
- Worker Service: For background processing
- Infra-only: For infrastructure components only

### Can I customize templates?
The templates are designed to be opinionated but flexible. You can modify the generated code to meet your specific requirements while keeping the core structure intact.

## Deployment

### How does deployment work?
The platform uses GitOps with ArgoCD. When you push changes to your repository, the CI/CD pipeline builds and tests your code, then ArgoCD deploys it to the cluster.

### How do I promote to different environments?
Promotions are handled through the promotion workflow. You can use the promotion script or follow the manual process outlined in the deployment documentation.

### What happens if a deployment fails?
The platform has health checks and rollback mechanisms. If a deployment fails, it will automatically rollback to the previous stable version, or you can manually trigger a rollback.

## Security

### How is security handled?
Security is built into the platform through OPA policies, image scanning, infrastructure hardening, and RBAC. All services follow security best practices by default.

### How do I handle secrets?
Secrets are managed through the platform's secret management system. Never commit secrets to your code repository. Use the platform's secret injection mechanisms instead.

### Are there security policies I need to follow?
Yes, the platform enforces security policies through OPA Gatekeeper, including required labels, approved base images, resource limits, and more.

## Troubleshooting

### My service isn't deploying, what should I check?
1. Check the ArgoCD dashboard for sync status
2. Review CI/CD pipeline logs
3. Check your Kubernetes manifests for errors
4. Verify resource requirements and limits

### How do I check my service logs?
You can view logs through the Backstage UI, or use kubectl directly:
```bash
kubectl logs -n <namespace> <pod-name>
```

### How do I get help when stuck?
- Check the troubleshooting guide
- Ask in #platform-users Slack channel
- Submit a ticket to the platform team
- Review the documentation

## Performance

### How do I monitor my service?
The platform provides built-in monitoring with Prometheus and Grafana. You can also implement custom metrics and health checks.

### How do I scale my service?
Scaling is configured in your Kubernetes manifests. The platform supports both horizontal and vertical scaling based on metrics.

### What are the resource limits?
Resource limits depend on your team's quota and the platform policies. Check with your team lead for specific limits.

## Best Practices

### What are the recommended practices?
- Follow the established patterns in the templates
- Write comprehensive tests
- Document your service properly
- Monitor key metrics
- Follow security guidelines
- Use semantic versioning

### How should I structure my code?
Follow the structure provided by the templates. Keep concerns separated and follow the twelve-factor app methodology.

### How do I handle dependencies?
Manage dependencies through proper package managers. Keep dependencies updated and scan for vulnerabilities regularly.

## Support

### Who maintains the platform?
The platform engineering team maintains the IDP infrastructure and services.

### How do I suggest improvements?
Submit feature requests through the platform's GitHub repository or discuss in the #platform-feedback channel.

### Where can I find more documentation?
All platform documentation is available in the Backstage service catalog and the techdocs section.
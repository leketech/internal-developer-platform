# Service Templates

The Internal Developer Platform provides standardized templates to accelerate service creation while maintaining consistency and best practices.

## Available Templates

### Backend Service Template
- **Purpose**: For creating API services
- **Includes**: Express.js/Node.js base, Dockerfile, Kubernetes manifests, CI/CD pipeline
- **Best for**: HTTP APIs, microservices with REST endpoints

### Worker Service Template
- **Purpose**: For background processing services
- **Includes**: Worker pattern implementation, Dockerfile, Kubernetes manifests
- **Best for**: Queue processors, scheduled tasks, background jobs

### Infra-only Template
- **Purpose**: For infrastructure-only components
- **Includes**: Terraform modules, CI/CD for infrastructure
- **Best for**: Databases, message queues, networking components

## Template Structure

Each template provides:

### Code Structure
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

### Pre-configured Features

- **Security**: Built-in security best practices
- **Observability**: Pre-configured logging, metrics, and tracing
- **Testing**: Unit and integration test frameworks
- **Documentation**: TechDocs integration
- **CI/CD**: GitHub Actions workflows
- **GitOps**: ArgoCD ready configurations

## Using Templates

1. Navigate to "Create..." in Backstage
2. Select your desired template
3. Fill in the required information
4. Review and create your service
5. Clone the generated repository
6. Customize as needed

## Customizing Templates

Templates are designed to be opinionated but flexible. You can:

- Add additional dependencies
- Modify the Dockerfile for specific requirements
- Adjust Kubernetes resource limits
- Add environment-specific configurations
- Extend the CI/CD pipeline

## Best Practices

- Follow the established patterns for consistency
- Add comprehensive documentation
- Include appropriate tests
- Use semantic versioning
- Follow security guidelines
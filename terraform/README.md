# Terraform Infrastructure

This directory contains reusable Terraform modules for provisioning cloud infrastructure as part of the Internal Developer Platform.

## Module Structure

The infrastructure is organized into reusable modules:

- **modules/** - Reusable infrastructure modules
  - **vpc/** - Virtual Private Cloud configuration
  - **eks/** - Elastic Kubernetes Service cluster
  - **iam-irsa/** - IAM roles for Service Accounts
  - **rds/** - Relational Database Service
  - **dynamodb/** - DynamoDB tables
  - **s3/** - Simple Storage Service buckets

- **environments/** - Environment-specific configurations
  - **dev/** - Development environment
  - **staging/** - Staging environment
  - **prod/** - Production environment

## Getting Started

### Prerequisites

- Terraform >= 1.0
- AWS CLI configured with appropriate permissions
- AWS credentials with necessary permissions for resource creation

### Usage

Each environment directory contains a main Terraform configuration that uses the modules from the `modules/` directory. To deploy infrastructure for a specific environment:

```bash
cd environments/dev
terraform init
terraform plan
terraform apply
```

### Module Details

#### VPC Module

Creates a Virtual Private Cloud with public and private subnets across multiple availability zones.

#### EKS Module

Creates an Elastic Kubernetes Service cluster with node groups and associated networking.

#### IAM-IRSA Module

Sets up IAM roles for Kubernetes Service Accounts to enable secure access to AWS services.

#### RDS Module

Creates managed relational databases with backups, monitoring, and security configurations.

#### DynamoDB Module

Creates managed NoSQL databases with auto-scaling and backup capabilities.

#### S3 Module

Creates S3 buckets with appropriate security, lifecycle policies, and cross-region replication options.

## Security Considerations

- All resources are created with appropriate security configurations by default
- Secrets are managed externally via AWS Secrets Manager
- Network access is restricted to necessary ports and protocols
- IAM roles follow principle of least privilege

## Best Practices

- Use versioned modules for consistent deployments
- Enable Terraform state locking and backend storage
- Implement automated testing for infrastructure changes
- Use Terraform Cloud or Enterprise for enhanced collaboration and security
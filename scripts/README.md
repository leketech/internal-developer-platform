# Platform Scripts

This directory contains utility scripts for managing the Internal Developer Platform.

## Available Scripts

### `bootstrap-cluster.sh`

A script to bootstrap a new Kubernetes cluster with the essential components of the Internal Developer Platform.

#### Usage

```bash
# Basic usage
./bootstrap-cluster.sh

# With custom parameters
CLUSTER_NAME=my-cluster NODE_COUNT=5 ./bootstrap-cluster.sh

# Using command line options
./bootstrap-cluster.sh --cluster-name my-cluster --node-count 3 --namespace platform
```

#### Options

- `-c, --cluster-name NAME`: Cluster name (default: idp-cluster)
- `-r, --region REGION`: AWS region (default: us-east-1)
- `-t, --node-type TYPE`: Node instance type (default: t3.medium)
- `-n, --node-count COUNT`: Number of nodes (default: 3)
- `--namespace NS`: Namespace for platform components (default: platform)
- `--no-argocd`: Skip ArgoCD installation
- `--no-backstage`: Skip Backstage installation
- `--no-monitoring`: Skip monitoring stack installation
- `-h, --help`: Show help message

#### Features

- Installs ArgoCD for GitOps
- Sets up Backstage for developer portal
- Configures monitoring stack (Prometheus + Grafana)
- Installs NGINX Ingress Controller
- Creates necessary namespaces

### `promote-environment.sh`

A script to promote applications between environments (dev -> staging -> prod) following GitOps principles.

#### Usage

```bash
# Basic usage
./promote-environment.sh -a my-app -r https://github.com/leketech/internal-developer-platform.git

# With custom parameters
SOURCE_ENV=dev TARGET_ENV=staging APP_NAME=my-app GIT_REPO=https://github.com/leketech/internal-developer-platform.git ./promote-environment.sh

# Using command line options
./promote-environment.sh -s dev -t staging -a my-app -r https://github.com/leketech/internal-developer-platform.git --auto-confirm
```

#### Options

- `-s, --source-env ENV`: Source environment (dev, staging) [default: dev]
- `-t, --target-env ENV`: Target environment (staging, prod) [default: staging]
- `-a, --app-name NAME`: Application name to promote
- `-r, --git-repo URL`: Git repository URL
- `-b, --branch BRANCH`: Git branch [default: main]
- `--auto-confirm`: Automatically confirm promotion without prompting
- `--dry-run`: Perform a dry run without making changes
- `-h, --help`: Show help message

#### Features

- Validates promotion path (dev -> staging -> prod)
- Updates environment-specific configurations
- Creates Git commit with promotion changes
- Triggers ArgoCD sync for deployment
- Sends notifications about promotions
- Supports dry-run mode for testing

## Prerequisites

Both scripts require the following tools to be installed:

- `kubectl` - Kubernetes command-line tool
- `helm` - Kubernetes package manager
- `aws` - AWS command-line interface
- `git` - Version control system

## Best Practices

1. Always review the changes before confirming promotions
2. Use dry-run mode to test scripts before applying to production
3. Ensure proper RBAC permissions before running scripts
4. Monitor the cluster after running bootstrap scripts
5. Keep scripts versioned alongside your infrastructure code

## Security Considerations

- Store sensitive credentials in environment variables or secure vaults
- Never commit credentials to version control
- Use IAM roles and policies to limit permissions
- Regularly rotate access keys and certificates
- Enable audit logging for all operations
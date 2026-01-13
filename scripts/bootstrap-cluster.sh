#!/bin/bash

# Bootstrap script for setting up a new cluster with the Internal Developer Platform components

set -euo pipefail

# Default values
CLUSTER_NAME="${CLUSTER_NAME:-idp-cluster}"
REGION="${REGION:-us-east-1}"
NODE_INSTANCE_TYPE="${NODE_INSTANCE_TYPE:-t3.medium}"
NODE_COUNT="${NODE_COUNT:-3}"
NAMESPACE="${NAMESPACE:-platform}"
INSTALL_ARGOCD="${INSTALL_ARGOCD:-true}"
INSTALL_BACKSTAGE="${INSTALL_BACKSTAGE:-true}"
INSTALL_MONITORING="${INSTALL_MONITORING:-true}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."

    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed"
        exit 1
    fi

    if ! command -v helm &> /dev/null; then
        print_error "helm is not installed"
        exit 1
    fi

    if ! command -v aws &> /dev/null; then
        print_error "aws cli is not installed"
        exit 1
    fi

    print_status "Prerequisites check passed"
}

# Function to create namespace
create_namespace() {
    print_status "Creating namespace: $NAMESPACE"
    
    kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
}

# Function to install ArgoCD
install_argocd() {
    if [[ "$INSTALL_ARGOCD" == "true" ]]; then
        print_status "Installing ArgoCD..."
        
        kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
        
        # Install ArgoCD using the official manifest
        kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
        
        print_status "Waiting for ArgoCD to be ready..."
        kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s
    fi
}

# Function to install Backstage
install_backstage() {
    if [[ "$INSTALL_BACKSTAGE" == "true" ]]; then
        print_status "Installing Backstage..."
        
        # Create a simple Backstage deployment
        cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backstage
  namespace: $NAMESPACE
  labels:
    app: backstage
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backstage
  template:
    metadata:
      labels:
        app: backstage
    spec:
      containers:
      - name: backstage
        image: ghcr.io/backstage/backstage:latest
        ports:
        - containerPort: 3000
        env:
        - name: APP_CONFIG_backend_baseUrl
          value: "http://localhost:3000"
        - name: APP_CONFIG_backend_cors_origin
          value: "*"
---
apiVersion: v1
kind: Service
metadata:
  name: backstage-service
  namespace: $NAMESPACE
spec:
  selector:
    app: backstage
  ports:
    - protocol: TCP
      port: 80
      targetPort: 3000
  type: LoadBalancer
EOF
    fi
}

# Function to install monitoring stack
install_monitoring() {
    if [[ "$INSTALL_MONITORING" == "true" ]]; then
        print_status "Installing monitoring stack (Prometheus + Grafana)..."
        
        # Add prometheus-community Helm repo
        helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
        helm repo update
        
        # Install kube-prometheus-stack
        helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
            --namespace $NAMESPACE --create-namespace \
            --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
            --set prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues=false \
            --set grafana.adminPassword=admin
    fi
}

# Function to setup ingress controller
setup_ingress() {
    print_status "Setting up NGINX Ingress Controller..."
    
    # Install NGINX Ingress Controller
    helm upgrade --install ingress-nginx ingress-nginx \
        --repo https://kubernetes.github.io/ingress-nginx \
        --namespace ingress-nginx --create-namespace
}

# Function to display installation summary
display_summary() {
    print_status "Installation completed!"
    echo
    print_status "Next steps:"
    echo "1. Get ArgoCD admin password: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
    echo "2. Port forward to access ArgoCD: kubectl port-forward svc/argocd-server -n argocd 8080:443"
    echo "3. Access Backstage: kubectl port-forward -n $NAMESPACE svc/backstage-service 3000:80"
    echo "4. Access Grafana: kubectl port-forward -n $NAMESPACE svc/prometheus-grafana 8081:80"
    echo
    print_status "Remember to configure your domain and TLS certificates for production use."
}

# Main execution
main() {
    print_status "Starting cluster bootstrap for Internal Developer Platform..."
    echo "Parameters:"
    echo "  CLUSTER_NAME: $CLUSTER_NAME"
    echo "  REGION: $REGION"
    echo "  NODE_INSTANCE_TYPE: $NODE_INSTANCE_TYPE"
    echo "  NODE_COUNT: $NODE_COUNT"
    echo "  NAMESPACE: $NAMESPACE"
    echo "  INSTALL_ARGOCD: $INSTALL_ARGOCD"
    echo "  INSTALL_BACKSTAGE: $INSTALL_BACKSTAGE"
    echo "  INSTALL_MONITORING: $INSTALL_MONITORING"
    echo

    check_prerequisites
    create_namespace
    install_argocd
    install_backstage
    setup_ingress
    install_monitoring
    display_summary
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--cluster-name)
            CLUSTER_NAME="$2"
            shift 2
            ;;
        -r|--region)
            REGION="$2"
            shift 2
            ;;
        -t|--node-type)
            NODE_INSTANCE_TYPE="$2"
            shift 2
            ;;
        -n|--node-count)
            NODE_COUNT="$2"
            shift 2
            ;;
        --namespace)
            NAMESPACE="$2"
            shift 2
            ;;
        --no-argocd)
            INSTALL_ARGOCD="false"
            shift
            ;;
        --no-backstage)
            INSTALL_BACKSTAGE="false"
            shift
            ;;
        --no-monitoring)
            INSTALL_MONITORING="false"
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "Bootstrap a new cluster with Internal Developer Platform components"
            echo
            echo "Options:"
            echo "  -c, --cluster-name NAME     Cluster name (default: idp-cluster)"
            echo "  -r, --region REGION        AWS region (default: us-east-1)"
            echo "  -t, --node-type TYPE       Node instance type (default: t3.medium)"
            echo "  -n, --node-count COUNT     Number of nodes (default: 3)"
            echo "  --namespace NS             Namespace for platform components (default: platform)"
            echo "  --no-argocd               Skip ArgoCD installation"
            echo "  --no-backstage            Skip Backstage installation"
            echo "  --no-monitoring           Skip monitoring stack installation"
            echo "  -h, --help                Show this help message"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Execute main function
main
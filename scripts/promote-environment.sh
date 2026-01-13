#!/bin/bash

# Script to promote applications between environments in the Internal Developer Platform

set -euo pipefail

# Default values
SOURCE_ENV="${SOURCE_ENV:-dev}"
TARGET_ENV="${TARGET_ENV:-staging}"
APP_NAME="${APP_NAME:-}"
GIT_REPO="${GIT_REPO:-}"
GIT_BRANCH="${GIT_BRANCH:-main}"
AUTO_CONFIRM="${AUTO_CONFIRM:-false}"
DRY_RUN="${DRY_RUN:-false}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

print_header() {
    echo -e "${BLUE}[HEADER]${NC} $1"
}

# Function to validate environment names
validate_environments() {
    valid_envs=("dev" "staging" "prod")
    
    if [[ ! " ${valid_envs[@]} " =~ " ${SOURCE_ENV} " ]]; then
        print_error "Invalid source environment: $SOURCE_ENV"
        exit 1
    fi
    
    if [[ ! " ${valid_envs[@]} " =~ " ${TARGET_ENV} " ]]; then
        print_error "Invalid target environment: $TARGET_ENV"
        exit 1
    fi
    
    # Check that source and target are different
    if [[ "$SOURCE_ENV" == "$TARGET_ENV" ]]; then
        print_error "Source and target environments must be different"
        exit 1
    fi
    
    # Check promotion order (dev -> staging -> prod)
    case "$SOURCE_ENV" in
        "dev")
            if [[ "$TARGET_ENV" != "staging" && "$TARGET_ENV" != "prod" ]]; then
                print_error "From dev, you can only promote to staging or prod"
                exit 1
            fi
            ;;
        "staging")
            if [[ "$TARGET_ENV" != "prod" ]]; then
                print_error "From staging, you can only promote to prod"
                exit 1
            fi
            ;;
        "prod")
            print_error "Cannot promote from prod environment"
            exit 1
            ;;
    esac
}

# Function to validate required parameters
validate_params() {
    if [[ -z "$APP_NAME" ]]; then
        print_error "APP_NAME is required"
        exit 1
    fi
    
    if [[ -z "$GIT_REPO" ]]; then
        print_error "GIT_REPO is required"
        exit 1
    fi
}

# Function to confirm promotion
confirm_promotion() {
    if [[ "$AUTO_CONFIRM" == "true" ]]; then
        return 0
    fi
    
    print_header "Promotion Summary"
    echo "App: $APP_NAME"
    echo "From: $SOURCE_ENV"
    echo "To: $TARGET_ENV"
    echo "Repo: $GIT_REPO"
    echo "Branch: $GIT_BRANCH"
    echo
    
    read -p "Do you want to proceed with the promotion? (yes/no): " -r
    echo
    if [[ ! $REPLY =~ ^[Yy]([Ee][Ss])?$ ]]; then
        print_status "Promotion cancelled by user"
        exit 0
    fi
}

# Function to clone and prepare git repo
prepare_git_repo() {
    print_status "Cloning repository: $GIT_REPO"
    
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    git clone "$GIT_REPO" repo
    cd repo
    
    git checkout "$GIT_BRANCH"
    
    echo "$temp_dir/repo"
}

# Function to update environment configuration
update_environment_config() {
    local repo_path="$1"
    local env_path="$repo_path/gitops/clusters/$TARGET_ENV"
    
    if [[ ! -d "$env_path" ]]; then
        print_error "Environment path does not exist: $env_path"
        exit 1
    fi
    
    print_status "Updating configuration for $TARGET_ENV environment"
    
    # Update image tags, versions, or other environment-specific configurations
    # This is a placeholder - actual implementation depends on your configuration structure
    find "$env_path" -name "*.yaml" -exec sed -i.bak "s|${SOURCE_ENV}|${TARGET_ENV}|g" {} \;
    
    # Update the app version if it's specified in the configuration
    if [[ -f "$env_path/app-of-apps.yaml" ]]; then
        sed -i.bak "s|$APP_NAME-$SOURCE_ENV|$APP_NAME-$TARGET_ENV|g" "$env_path/app-of-apps.yaml"
    fi
}

# Function to create git commit and push
commit_and_push() {
    local repo_path="$1"
    
    cd "$repo_path"
    
    git config user.name "IDP Bot"
    git config user.email "bot@idp.internal"
    
    git add .
    git commit -m "Promote $APP_NAME from $SOURCE_ENV to $TARGET_ENV"
    
    if [[ "$DRY_RUN" == "false" ]]; then
        git push origin "$GIT_BRANCH"
        print_status "Changes pushed to repository"
    else
        print_status "DRY RUN: Would have pushed changes to repository"
    fi
}

# Function to trigger ArgoCD sync
trigger_argocd_sync() {
    if [[ "$DRY_RUN" == "true" ]]; then
        print_status "DRY RUN: Would have triggered ArgoCD sync for $APP_NAME in $TARGET_ENV"
        return
    fi
    
    print_status "Triggering ArgoCD sync for $APP_NAME in $TARGET_ENV"
    
    # Wait for ArgoCD to pick up the changes
    sleep 5
    
    # Sync the application in ArgoCD
    argocd app sync "$APP_NAME-$TARGET_ENV" --timeout 300 || {
        print_warning "Failed to sync $APP_NAME-$TARGET_ENV in ArgoCD"
        print_warning "Please check ArgoCD dashboard for more details"
    }
}

# Function to validate promotion readiness
validate_promotion_readiness() {
    print_status "Validating promotion readiness..."
    
    # Check if the source environment has the application running
    if [[ "$DRY_RUN" == "false" ]]; then
        if ! kubectl get ns "$SOURCE_ENV" &>/dev/null; then
            print_warning "Source namespace $SOURCE_ENV does not exist in current cluster"
        fi
        
        # Check if the application is healthy in source environment
        if command -v argocd &>/dev/null; then
            local health_status=$(argocd app get "$APP_NAME-$SOURCE_ENV" --output json | jq -r '.status.health.status' 2>/dev/null || echo "Unknown")
            if [[ "$health_status" != "Healthy" ]]; then
                print_warning "Application $APP_NAME-$SOURCE_ENV is not healthy ($health_status)"
                if [[ "$AUTO_CONFIRM" != "true" ]]; then
                    read -p "Continue with promotion anyway? (yes/no): " -r
                    if [[ ! $REPLY =~ ^[Yy]([Ee][Ss])?$ ]]; then
                        print_status "Promotion cancelled by user"
                        exit 0
                    fi
                fi
            fi
        fi
    fi
}

# Function to send notification
send_notification() {
    print_status "Sending promotion notification..."
    
    # Placeholder for sending notifications (Slack, email, etc.)
    # This would integrate with your notification system
    local message="Application $APP_NAME promoted from $SOURCE_ENV to $TARGET_ENV by $(whoami) at $(date)"
    
    if [[ "$DRY_RUN" == "false" ]]; then
        # Example: Send to Slack webhook
        # curl -X POST -H 'Content-type: application/json' \
        #   --data "{\"text\":\"$message\"}" \
        #   $SLACK_WEBHOOK_URL
        echo "$message" >> /tmp/idp-promotion-log.txt
    else
        print_status "DRY RUN: Would have sent notification: $message"
    fi
}

# Main execution
main() {
    print_header "Internal Developer Platform - Environment Promotion Tool"
    echo "Parameters:"
    echo "  Source Environment: $SOURCE_ENV"
    echo "  Target Environment: $TARGET_ENV"
    echo "  Application Name: $APP_NAME"
    echo "  Git Repository: $GIT_REPO"
    echo "  Git Branch: $GIT_BRANCH"
    echo "  Dry Run: $DRY_RUN"
    echo "  Auto Confirm: $AUTO_CONFIRM"
    echo
    
    validate_params
    validate_environments
    validate_promotion_readiness
    confirm_promotion
    
    print_status "Starting promotion process..."
    
    local repo_path=$(prepare_git_repo)
    update_environment_config "$repo_path"
    commit_and_push "$repo_path"
    trigger_argocd_sync
    send_notification
    
    # Clean up
    rm -rf "$repo_path"
    
    print_status "Promotion completed successfully!"
    echo
    print_status "Next steps:"
    echo "1. Monitor the deployment in ArgoCD dashboard"
    echo "2. Verify application health in $TARGET_ENV"
    echo "3. Run smoke tests if available"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--source-env)
            SOURCE_ENV="$2"
            shift 2
            ;;
        -t|--target-env)
            TARGET_ENV="$2"
            shift 2
            ;;
        -a|--app-name)
            APP_NAME="$2"
            shift 2
            ;;
        -r|--git-repo)
            GIT_REPO="$2"
            shift 2
            ;;
        -b|--branch)
            GIT_BRANCH="$2"
            shift 2
            ;;
        --auto-confirm)
            AUTO_CONFIRM="true"
            shift
            ;;
        --dry-run)
            DRY_RUN="true"
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "Promote applications between environments in the Internal Developer Platform"
            echo
            echo "Options:"
            echo "  -s, --source-env ENV     Source environment (dev, staging) [default: dev]"
            echo "  -t, --target-env ENV     Target environment (staging, prod) [default: staging]"
            echo "  -a, --app-name NAME      Application name to promote"
            echo "  -r, --git-repo URL       Git repository URL"
            echo "  -b, --branch BRANCH      Git branch [default: main]"
            echo "  --auto-confirm          Automatically confirm promotion without prompting"
            echo "  --dry-run               Perform a dry run without making changes"
            echo "  -h, --help              Show this help message"
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
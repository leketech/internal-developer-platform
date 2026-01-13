# Production Environment Infrastructure

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }

  # Configure backend for state management
  backend "s3" {
    bucket         = "idp-terraform-state-prod"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "idp-terraform-locks"
  }
}

provider "aws" {
  region = "us-east-1"
}

# VPC Configuration
module "vpc" {
  source = "../../modules/vpc"

  name                           = "idp-prod-vpc"
  cidr_block                     = "10.30.0.0/16"
  availability_zones             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnets_cidr_blocks     = ["10.30.1.0/24", "10.30.2.0/24", "10.30.3.0/24"]
  private_subnets_cidr_blocks    = ["10.30.101.0/24", "10.30.102.0/24", "10.30.103.0/24"]
  enable_nat_gateway             = true

  tags = {
    Environment = "prod"
    Project     = "IDP"
    Terraform   = "true"
  }
}

# EKS Cluster
module "eks" {
  source = "../../modules/eks"

  cluster_name    = "idp-prod-eks"
  cluster_version = "1.28"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnet_ids

  node_group_name     = "prod-node-group"
  node_instance_types = ["t3.medium"]
  min_size           = 3
  max_size           = 10
  desired_size       = 5

  tags = {
    Environment = "prod"
    Project     = "IDP"
    Terraform   = "true"
  }
}

# Example RDS Instance
module "rds" {
  source = "../../modules/rds"

  identifier = "idp-prod-postgres"
  engine     = "postgres"
  engine_version = "13.7"
  instance_class = "db.t3.medium"
  allocated_storage = 100
  max_allocated_storage = 500
  storage_encrypted = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
  allowed_security_groups = [module.eks.node_security_group_id]

  username = var.db_username
  password = var.db_password
  database_name = "prod_database"

  backup_retention_period = 30

  tags = {
    Environment = "prod"
    Project     = "IDP"
    Terraform   = "true"
  }
}

# Example DynamoDB Table
module "dynamodb" {
  source = "../../modules/dynamodb"

  name = "idp-prod-table"
  hash_key = "id"
  billing_mode = "PROVISIONED"
  read_capacity = 20
  write_capacity = 10

  server_side_encryption_enabled = true
  point_in_time_recovery_enabled = true

  tags = {
    Environment = "prod"
    Project     = "IDP"
    Terraform   = "true"
  }
}

# Example S3 Bucket
module "s3" {
  source = "../../modules/s3"

  bucket_name = "idp-prod-artifacts-${random_string.suffix.result}"

  versioning_enabled = true
  lifecycle_rules = [
    {
      id = "move-old-versions-to-ia"
      enabled = true
      noncurrent_version_transitions = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 90
          storage_class = "GLACIER"
        }
      ]
    }
  ]

  tags = {
    Environment = "prod"
    Project     = "IDP"
    Terraform   = "true"
  }
}

# Random string for unique bucket name
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Output values
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "rds_endpoint" {
  description = "Connection endpoint for the database"
  value       = module.rds.endpoint
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = module.dynamodb.name
}

output "s3_bucket_id" {
  description = "ID of the S3 bucket"
  value       = module.s3.bucket_id
}
# IAM-IRSA Module
# Creates IAM roles for Kubernetes Service Accounts to enable secure access to AWS services

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_oidc_issuer_url" {
  description = "URL of the EKS cluster OIDC issuer"
  type        = string
}

variable "service_account_namespace" {
  description = "Namespace of the Kubernetes service account"
  type        = string
  default     = "default"
}

variable "service_account_name" {
  description = "Name of the Kubernetes service account"
  type        = string
}

variable "additional_policy_arns" {
  description = "Additional policy ARNs to attach to the role"
  type        = list(string)
  default     = []
}

variable "role_name" {
  description = "Name of the IAM role to create"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Terraform = "true"
    Project   = "IDP"
  }
}

# Create IAM OIDC Provider for the EKS cluster
resource "aws_iam_openid_connect_provider" "oidc_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster.certificates[0].sha1_fingerprint]
  url             = var.cluster_oidc_issuer_url

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-oidc-provider"
    }
  )
}

# Data source to get TLS certificate for the cluster OIDC issuer
data "tls_certificate" "cluster" {
  url = var.cluster_oidc_issuer_url
}

# Create IAM role for the service account
resource "aws_iam_role" "irsa_role" {
  name = var.role_name != "" ? var.role_name : "${var.cluster_name}-${var.service_account_namespace}-${var.service_account_name}-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.oidc_provider.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(var.cluster_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:${var.service_account_namespace}:${var.service_account_name}"
            "${replace(var.cluster_oidc_issuer_url, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = var.role_name != "" ? var.role_name : "${var.cluster_name}-${var.service_account_namespace}-${var.service_account_name}-irsa-role"
    }
  )
}

# Attach additional policies to the role
resource "aws_iam_role_policy_attachment" "additional_policies" {
  count      = length(var.additional_policy_arns)
  role       = aws_iam_role.irsa_role.name
  policy_arn = var.additional_policy_arns[count.index]
}

# Create a default policy if no additional policies are provided
resource "aws_iam_policy" "default_policy" {
  count  = length(var.additional_policy_arns) == 0 ? 1 : 0
  name   = "${var.cluster_name}-${var.service_account_namespace}-${var.service_account_name}-default-policy"
  policy = data.aws_iam_policy_document.default_policy[0].json

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-${var.service_account_namespace}-${var.service_account_name}-default-policy"
    }
  )
}

data "aws_iam_policy_document" "default_policy" {
  count = length(var.additional_policy_arns) == 0 ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "default_policy" {
  count      = length(var.additional_policy_arns) == 0 ? 1 : 0
  role       = aws_iam_role.irsa_role.name
  policy_arn = aws_iam_policy.default_policy[0].arn
}

output "role_name" {
  description = "Name of the created IAM role"
  value       = aws_iam_role.irsa_role.name
}

output "role_arn" {
  description = "ARN of the created IAM role"
  value       = aws_iam_role.irsa_role.arn
}

output "role_id" {
  description = "ID of the created IAM role"
  value       = aws_iam_role.irsa_role.id
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC provider"
  value       = aws_iam_openid_connect_provider.oidc_provider.arn
}

output "service_account_namespace" {
  description = "Namespace of the service account"
  value       = var.service_account_namespace
}

output "service_account_name" {
  description = "Name of the service account"
  value       = var.service_account_name
}
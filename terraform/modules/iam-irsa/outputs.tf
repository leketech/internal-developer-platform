# IAM-IRSA Module Outputs

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
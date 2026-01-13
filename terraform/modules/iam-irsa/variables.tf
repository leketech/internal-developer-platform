# IAM-IRSA Module Variables

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
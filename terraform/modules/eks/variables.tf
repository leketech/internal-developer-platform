# EKS Module Variables

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "idp-eks-cluster"
}

variable "cluster_version" {
  description = "Kubernetes version for the cluster"
  type        = string
  default     = "1.28"
}

variable "vpc_id" {
  description = "ID of the VPC where the cluster will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs where worker nodes will be launched"
  type        = list(string)
}

variable "cluster_endpoint_private_access" {
  description = "Enable private access to the cluster endpoint"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access" {
  description = "Enable public access to the cluster endpoint"
  type        = bool
  default     = true
}

variable "cluster_create_timeout" {
  description = "Timeout value when creating the EKS cluster"
  type        = string
  default     = "30m"
}

variable "cluster_update_timeout" {
  description = "Timeout value when updating the EKS cluster"
  type        = string
  default     = "60m"
}

variable "cluster_delete_timeout" {
  description = "Timeout value when deleting the EKS cluster"
  type        = string
  default     = "15m"
}

variable "node_group_name" {
  description = "Name of the node group"
  type        = string
  default     = "default-node-group"
}

variable "node_instance_types" {
  description = "Instance types for the node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "min_size" {
  description = "Minimum number of nodes in the node group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of nodes in the node group"
  type        = number
  default     = 3
}

variable "desired_size" {
  description = "Desired number of nodes in the node group"
  type        = number
  default     = 2
}

variable "disk_size" {
  description = "Disk size in GiB for each node"
  type        = number
  default     = 20
}

variable "labels" {
  description = "Labels to apply to the node group"
  type        = map(string)
  default = {
    Environment = "production"
  }
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Terraform = "true"
    Project   = "IDP"
  }
}
# S3 Module Variables

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "region" {
  description = "AWS region for the bucket"
  type        = string
  default     = "us-east-1"
}

variable "versioning_enabled" {
  description = "Enable versioning for the bucket"
  type        = bool
  default     = true
}

variable "block_public_acls" {
  description = "Block public ACLs for the bucket"
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Block public policies for the bucket"
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Ignore public ACLs for the bucket"
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Restrict public buckets"
  type        = bool
  default     = true
}

variable "sse_algorithm" {
  description = "Server-side encryption algorithm"
  type        = string
  default     = "AES256"
}

variable "kms_master_key_id" {
  description = "KMS master key ID for SSE-KMS encryption"
  type        = string
  default     = null
}

variable "lifecycle_rules" {
  description = "List of lifecycle rules for the bucket"
  type        = list(any)
  default     = []
}

variable "cors_rules" {
  description = "List of CORS rules for the bucket"
  type        = list(any)
  default     = []
}

variable "website_enabled" {
  description = "Enable static website hosting"
  type        = bool
  default     = false
}

variable "website_index_document" {
  description = "Index document for the website"
  type        = string
  default     = "index.html"
}

variable "website_error_document" {
  description = "Error document for the website"
  type        = string
  default     = "error.html"
}

variable "notification_configuration" {
  description = "Notification configuration for the bucket"
  type        = any
  default     = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Terraform = "true"
    Project   = "IDP"
  }
}
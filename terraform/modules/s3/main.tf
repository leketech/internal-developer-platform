# S3 Module
# Creates S3 buckets with appropriate security, lifecycle policies, and cross-region replication options

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

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

# S3 Bucket
resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name

  tags = merge(
    var.tags,
    {
      Name = var.bucket_name
    }
  )
}

# S3 Bucket Server Side Encryption Configuration
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.kms_master_key_id != null ? "aws:kms" : var.sse_algorithm
      kms_master_key_id = var.kms_master_key_id
    }
  }
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

# S3 Bucket Lifecycle Configuration
resource "aws_s3_bucket_lifecycle_configuration" "main" {
  count  = length(var.lifecycle_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.main.id

  dynamic "rule" {
    for_each = { for idx, rule in var.lifecycle_rules : idx => rule }
    content {
      id     = lookup(rule.value, "id", "rule-${rule.key}")
      status = lookup(rule.value, "status", "Enabled")

      dynamic "transition" {
        for_each = lookup(rule.value, "transitions", [])
        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }

      dynamic "expiration" {
        for_each = length(lookup(rule.value, "expiration", {})) > 0 ? [lookup(rule.value, "expiration", {})] : []
        content {
          days = expiration.value.days
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = lookup(rule.value, "noncurrent_version_transitions", [])
        content {
          noncurrent_days = noncurrent_version_transition.value.days
          storage_class   = noncurrent_version_transition.value.storage_class
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = length(lookup(rule.value, "noncurrent_version_expiration", {})) > 0 ? [lookup(rule.value, "noncurrent_version_expiration", {})] : []
        content {
          noncurrent_days = noncurrent_version_expiration.value.days
        }
      }
    }
  }
}

# S3 Bucket CORS Configuration
resource "aws_s3_bucket_cors_configuration" "main" {
  count  = length(var.cors_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.main.id

  dynamic "cors_rule" {
    for_each = { for idx, rule in var.cors_rules : idx => rule }
    content {
      allowed_headers = lookup(cors_rule.value, "allowed_headers", ["*"])
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = lookup(cors_rule.value, "expose_headers", [])
      max_age_seconds = lookup(cors_rule.value, "max_age_seconds", 3000)
    }
  }
}

# S3 Bucket Website Configuration
resource "aws_s3_bucket_website_configuration" "main" {
  count  = var.website_enabled ? 1 : 0
  bucket = aws_s3_bucket.main.id

  index_document {
    suffix = var.website_index_document
  }

  error_document {
    key = var.website_error_document
  }
}

# S3 Bucket Notification Configuration
resource "aws_s3_bucket_notification" "main" {
  count  = length(keys(var.notification_configuration)) > 0 ? 1 : 0
  bucket = aws_s3_bucket.main.id

  dynamic "lambda_function" {
    for_each = lookup(var.notification_configuration, "lambda_functions", [])
    content {
      lambda_function_arn = lambda_function.value.lambda_function_arn
      events              = lambda_function.value.events
      filter_prefix       = lookup(lambda_function.value, "filter_prefix", null)
      filter_suffix       = lookup(lambda_function.value, "filter_suffix", null)
    }
  }

  dynamic "topic" {
    for_each = lookup(var.notification_configuration, "topics", [])
    content {
      topic_arn   = topic.value.topic_arn
      events      = topic.value.events
      filter_prefix = lookup(topic.value, "filter_prefix", null)
      filter_suffix = lookup(topic.value, "filter_suffix", null)
    }
  }

  dynamic "queue" {
    for_each = lookup(var.notification_configuration, "queues", [])
    content {
      queue_arn   = queue.value.queue_arn
      events      = queue.value.events
      filter_prefix = lookup(queue.value, "filter_prefix", null)
      filter_suffix = lookup(queue.value, "filter_suffix", null)
    }
  }
}

# S3 Bucket Policy (if needed for specific access patterns)
resource "aws_s3_bucket_policy" "main" {
  count  = var.block_public_policy && !var.block_public_acls ? 1 : 0  # Only if we want to explicitly deny public access
  bucket = aws_s3_bucket.main.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyInsecureConnections"
        Effect = "Deny"
        Principal = "*"
        Action  = "s3:*"
        Resource = [
          "${aws_s3_bucket.main.arn}",
          "${aws_s3_bucket.main.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

output "bucket_id" {
  description = "ID of the S3 bucket"
  value       = aws_s3_bucket.main.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.main.arn
}

output "bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = aws_s3_bucket.main.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket"
  value       = aws_s3_bucket.main.bucket_regional_domain_name
}

output "website_endpoint" {
  description = "Website endpoint of the S3 bucket (if website hosting is enabled)"
  value       = var.website_enabled ? aws_s3_bucket_website_configuration.main[0].website_endpoint : null
}

output "website_domain" {
  description = "Website domain of the S3 bucket (if website hosting is enabled)"
  value       = var.website_enabled ? aws_s3_bucket_website_configuration.main[0].website_domain : null
}

output "region" {
  description = "AWS region of the S3 bucket"
  value       = aws_s3_bucket.main.region
}
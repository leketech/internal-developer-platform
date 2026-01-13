# DynamoDB Module
# Creates managed NoSQL databases with auto-scaling and backup capabilities

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

variable "name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "hash_key" {
  description = "Hash key (partition key) name"
  type        = string
}

variable "range_key" {
  description = "Range key (sort key) name"
  type        = string
  default     = null
}

variable "billing_mode" {
  description = "Billing mode for the table (PROVISIONED or PAY_PER_REQUEST)"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "read_capacity" {
  description = "Read capacity units for PROVISIONED billing mode"
  type        = number
  default     = 5
}

variable "write_capacity" {
  description = "Write capacity units for PROVISIONED billing mode"
  type        = number
  default     = 5
}

variable "server_side_encryption_enabled" {
  description = "Enable server-side encryption"
  type        = bool
  default     = true
}

variable "point_in_time_recovery_enabled" {
  description = "Enable point in time recovery"
  type        = bool
  default     = true
}

variable "stream_enabled" {
  description = "Enable DynamoDB stream"
  type        = bool
  default     = false
}

variable "stream_view_type" {
  description = "Type of data to capture in stream"
  type        = string
  default     = "NEW_AND_OLD_IMAGES"
}

variable "attribute_definitions" {
  description = "Attribute definitions for the table"
  type        = list(map(string))
  default     = []
}

variable "global_secondary_indexes" {
  description = "Global secondary indexes for the table"
  type        = list(map(any))
  default     = []
}

variable "local_secondary_indexes" {
  description = "Local secondary indexes for the table"
  type        = list(map(any))
  default     = []
}

variable "ttl_attribute_name" {
  description = "Name of the attribute to use for TTL"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Terraform = "true"
    Project   = "IDP"
  }
}

# Define attributes
locals {
  base_attributes = [
    {
      name = var.hash_key
      type = "S"  # Assuming string type for hash key, could be made configurable
    }
  ]

  all_attributes = concat(
    local.base_attributes,
    var.range_key != null ? [{
      name = var.range_key
      type = "S"  # Assuming string type for range key, could be made configurable
    }] : [],
    var.attribute_definitions...
  )
}

# DynamoDB Table
resource "aws_dynamodb_table" "main" {
  name         = var.name
  billing_mode = var.billing_mode

  hash_key = var.hash_key
  range_key = var.range_key

  # Set capacity if using PROVISIONED billing
  read_capacity  = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
  write_capacity = var.billing_mode == "PROVISIONED" ? var.write_capacity : null

  dynamic "attribute" {
    for_each = { for attr in local.all_attributes : attr.name => attr }
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  dynamic "global_secondary_index" {
    for_each = { for index in var.global_secondary_indexes : index.name => index }
    content {
      name               = global_secondary_index.value.name
      hash_key           = global_secondary_index.value.hash_key
      range_key          = lookup(global_secondary_index.value, "range_key", null)
      write_capacity     = var.billing_mode == "PROVISIONED" ? lookup(global_secondary_index.value, "write_capacity", 5) : null
      read_capacity      = var.billing_mode == "PROVISIONED" ? lookup(global_secondary_index.value, "read_capacity", 5) : null
      projection_type    = lookup(global_secondary_index.value, "projection_type", "ALL")
    }
  }

  dynamic "local_secondary_index" {
    for_each = { for index in var.local_secondary_indexes : index.name => index }
    content {
      name            = local_secondary_index.value.name
      range_key       = local_secondary_index.value.range_key
      projection_type = lookup(local_secondary_index.value, "projection_type", "ALL")
    }
  }

  server_side_encryption {
    enabled = var.server_side_encryption_enabled
  }

  point_in_time_recovery {
    enabled = var.point_in_time_recovery_enabled
  }

  stream_enabled = var.stream_enabled
  stream_view_type = var.stream_enabled ? var.stream_view_type : null

  ttl {
    attribute_name = var.ttl_attribute_name
    enabled        = var.ttl_attribute_name != null
  }

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}

# Auto Scaling for read capacity if using PROVISIONED billing
resource "aws_appautoscaling_target" "read_target" {
  count              = var.billing_mode == "PROVISIONED" ? 1 : 0
  max_capacity       = var.read_capacity * 10
  min_capacity       = var.read_capacity
  resource_id        = "table/${aws_dynamodb_table.main.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "read_policy" {
  count              = var.billing_mode == "PROVISIONED" ? 1 : 0
  name               = "${var.name}-read-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.read_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.read_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.read_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 70.0
    scale_in_cooldown = 300
    scale_out_cooldown = 300

    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
  }
}

# Auto Scaling for write capacity if using PROVISIONED billing
resource "aws_appautoscaling_target" "write_target" {
  count              = var.billing_mode == "PROVISIONED" ? 1 : 0
  max_capacity       = var.write_capacity * 10
  min_capacity       = var.write_capacity
  resource_id        = "table/${aws_dynamodb_table.main.name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "write_policy" {
  count              = var.billing_mode == "PROVISIONED" ? 1 : 0
  name               = "${var.name}-write-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.write_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.write_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.write_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 70.0
    scale_in_cooldown = 300
    scale_out_cooldown = 300

    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }
  }
}

output "name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.main.name
}

output "arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.main.arn
}

output "stream_arn" {
  description = "ARN of the DynamoDB stream (if enabled)"
  value       = var.stream_enabled ? aws_dynamodb_table.main.stream_arn : null
}

output "stream_label" {
  description = "Label of the DynamoDB stream (if enabled)"
  value       = var.stream_enabled ? aws_dynamodb_table.main.stream_label : null
}

output "item_count" {
  description = "Number of items in the table"
  value       = aws_dynamodb_table.main.item_count
}

output "table_size_bytes" {
  description = "Size of the table in bytes"
  value       = aws_dynamodb_table.main.table_size_bytes
}

output "status" {
  description = "Status of the table"
  value       = aws_dynamodb_table.main.status
}
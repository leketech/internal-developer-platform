# DynamoDB Module Variables

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
# DynamoDB Module Outputs

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
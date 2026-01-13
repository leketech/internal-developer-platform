# RDS Module Outputs

output "endpoint" {
  description = "Connection endpoint for the database"
  value       = aws_db_instance.main.endpoint
}

output "address" {
  description = "Hostname of the database"
  value       = aws_db_instance.main.address
}

output "port" {
  description = "Port of the database"
  value       = aws_db_instance.main.port
}

output "database_name" {
  description = "Name of the database"
  value       = aws_db_instance.main.db_name
}

output "username" {
  description = "Master username for the database"
  value       = aws_db_instance.main.username
  sensitive   = true
}

output "host" {
  description = "Host endpoint for the database"
  value       = aws_db_instance.main.address
}

output "connection_url" {
  description = "Complete connection URL for the database"
  value       = "${var.engine}://${var.username}:${var.password}@${aws_db_instance.main.endpoint}/${aws_db_instance.main.db_name}"
  sensitive   = true
}

output "security_group_id" {
  description = "ID of the security group for the database"
  value       = aws_security_group.rds.id
}

output "db_subnet_group_name" {
  description = "Name of the DB subnet group"
  value       = aws_db_subnet_group.main.name
}

output "arn" {
  description = "ARN of the RDS instance"
  value       = aws_db_instance.main.arn
}
# RDS Module
# Creates managed relational databases with backups, monitoring, and security configurations

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

variable "identifier" {
  description = "Identifier for the RDS instance"
  type        = string
}

variable "engine" {
  description = "Database engine (mysql, postgres, etc.)"
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "Version of the database engine"
  type        = string
  default     = "13.7"
}

variable "instance_class" {
  description = "Instance class for the RDS instance"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Storage size in GB"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum storage size in GB for autoscaling"
  type        = number
  default     = 100
}

variable "storage_encrypted" {
  description = "Enable storage encryption"
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "ID of the VPC where the DB subnet group will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs where the database will be deployed"
  type        = list(string)
}

variable "allowed_security_groups" {
  description = "List of security group IDs that can access the database"
  type        = list(string)
  default     = []
}

variable "username" {
  description = "Master username for the database"
  type        = string
  sensitive   = true
}

variable "password" {
  description = "Master password for the database"
  type        = string
  sensitive   = true
}

variable "database_name" {
  description = "Name of the database to create"
  type        = string
  default     = ""
}

variable "port" {
  description = "Port for the database"
  type        = number
  default     = null
}

variable "backup_retention_period" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Daily time range for backups (UTC)"
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "Weekly time range for maintenance (UTC)"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot when destroying the database"
  type        = bool
  default     = false
}

variable "enabled_cloudwatch_logs_exports" {
  description = "List of log types to export to CloudWatch"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Terraform = "true"
    Project   = "IDP"
  }
}

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.identifier}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "${var.identifier}-subnet-group"
    }
  )
}

# Security Group for RDS
resource "aws_security_group" "rds" {
  name_prefix = "${var.identifier}-rds-"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.port != null ? var.port : var.engine == "postgres" ? 5432 : 3306
    to_port     = var.port != null ? var.port : var.engine == "postgres" ? 5432 : 3306
    protocol    = "tcp"
    description = "Database access"
    # Only allow from specified security groups
    security_groups = var.allowed_security_groups
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.identifier}-rds-security-group"
    }
  )
}

# RDS Instance
resource "aws_db_instance" "main" {
  identifier = var.identifier

  engine                      = var.engine
  engine_version              = var.engine_version
  instance_class              = var.instance_class
  allocated_storage           = var.allocated_storage
  max_allocated_storage       = var.max_allocated_storage
  storage_encrypted           = var.storage_encrypted
  db_subnet_group_name        = aws_db_subnet_group.main.name
  vpc_security_group_ids      = [aws_security_group.rds.id]
  username                    = var.username
  password                    = var.password
  db_name                     = var.database_name != "" ? var.database_name : null
  port                        = var.port
  backup_retention_period     = var.backup_retention_period
  backup_window               = var.backup_window
  maintenance_window          = var.maintenance_window
  skip_final_snapshot         = var.skip_final_snapshot
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  copy_tags_to_snapshot       = true

  # Enable performance insights for monitoring
  performance_insights_enabled = true

  tags = merge(
    var.tags,
    {
      Name = var.identifier
    }
  )
}

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
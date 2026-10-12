output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.this.id
}

output "web_sg_id" {
  description = "Security group for web tier"
  value       = module.web_sg.sg_id
}

output "db_sg_id" {
  description = "Security group for db tier"
  value       = module.db_sg.sg_id
}

output "web_instance_ids" {
  description = "IDs of the created web tier EC2 instances"
  value       = { for k, v in module.web_instances : k => v.instance_id }
}

output "rds_endpoint" {
  description = "Connection endpoint for RDS instance"
  value       = aws_db_instance.this.endpoint
}

output "rds_master_secret_arn" {
  description = "Secret Manager ARN holding the RDS master password"
  value       = aws_db_instance.this.master_user_secret[0].secret_arn
}
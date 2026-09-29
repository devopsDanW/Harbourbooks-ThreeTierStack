output "instance_id" {
  description = "ID of the created instance"
  value       = aws_instance.this.id
}

output "private_ip" {
  description = "Private IP of the instance"
  value       = aws_instance.this.private_ip
}

output "public_ip" {
  description = "Public IP of the instance (null unless associate_public_ip is true)"
  value       = aws_instance.this.public_ip
}


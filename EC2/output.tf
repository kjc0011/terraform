output "dev_instance_id" {
  description = "The ID of the developer instance"
  value       = aws_instance.dev.id
}

output "dev_public_ip" {
  description = "The public IP of the developer instance"
  value       = aws_eip.dev.public_ip
}

output "dev_security_group_id" {
  description = "The ID of the developer security group"
  value       = aws_security_group.dev.id
}
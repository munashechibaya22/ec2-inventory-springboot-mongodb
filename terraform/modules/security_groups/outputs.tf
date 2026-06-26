output "security_group_id" {
  value       = aws_security_group.app_sg.id
  description = "The ID of the application security group"
}

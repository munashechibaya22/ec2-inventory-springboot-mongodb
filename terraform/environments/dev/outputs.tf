output "public_ip" {
  value       = module.ec2.public_ip
  description = "The public IP address of the dev server"
}

output "instance_id" {
  value       = module.ec2.instance_id
  description = "The EC2 instance ID of the dev server"
}

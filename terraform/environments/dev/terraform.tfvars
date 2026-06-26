aws_region    = "eu-north-1"
aws_profile   = "devops"
environment   = "dev"
instance_type = "t3.micro"
key_name      = "YOUR_AWS_SSH_KEY_NAME" # Change to your actual AWS key pair name

tags = {
  Project     = "Inventory-Management"
  ManagedBy   = "Terraform"
  Environment = "dev"
  Owner       = "Munashe Chibaya"
}

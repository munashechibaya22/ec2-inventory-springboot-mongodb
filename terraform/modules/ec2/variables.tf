variable "subnet_id" {
  type        = string
  description = "The subnet ID to deploy the EC2 instance into"
}

variable "security_group_ids" {
  type        = list(string)
  description = "List of security group IDs to attach"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance size"
  default     = "t3.micro"
}

variable "key_name" {
  type        = string
  description = "SSH key pair name"
}

variable "environment" {
  type        = string
  description = "Deployment environment"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default     = {}
}

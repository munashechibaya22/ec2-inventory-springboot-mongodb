variable "aws_region" {
  type        = string
  description = "AWS Region to deploy resources"
  default     = "eu-north-1"
}

variable "aws_profile" {
  type        = string
  description = "AWS CLI Profile to use"
  default     = "devops"
}

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "dev"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance size"
  default     = "t3.micro"
}

variable "key_name" {
  type        = string
  description = "Name of the SSH key pair"
}

variable "tags" {
  type        = map(string)
  description = "Global tags to apply"
  default     = {}
}

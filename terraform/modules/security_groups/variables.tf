variable "vpc_id" {
  type        = string
  description = "ID of the VPC"
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

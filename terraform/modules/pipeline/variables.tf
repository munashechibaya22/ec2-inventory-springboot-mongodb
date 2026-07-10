variable "environment" {
  type        = string
  description = "The environment name (e.g., dev, prod)"
}

variable "repository_id" {
  type        = string
  description = "The GitHub repository path (e.g., owner/repo)"
}

variable "branch_name" {
  type        = string
  description = "The repository branch name to trigger builds"
  default     = "main"
}

variable "jenkins_server_url" {
  type        = string
  description = "The public URL of the Jenkins server"
}

variable "jenkins_project_name" {
  type        = string
  description = "The name of the Jenkins build/deploy job"
  default     = "Inventory-Management-Deploy"
}

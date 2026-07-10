output "ecr_repository_url" {
  value       = aws_ecr_repository.inventory_app.repository_url
  description = "The URL of the private ECR repository"
}

output "pipeline_arn" {
  value       = aws_codepipeline.pipeline.arn
  description = "The ARN of the CodePipeline"
}

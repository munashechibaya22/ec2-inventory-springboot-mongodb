# S3 Bucket for CodePipeline Artifacts
resource "aws_s3_bucket" "pipeline_artifacts" {
  bucket        = "munashe-inventory-pipeline-artifacts-dev"
  force_destroy = true
}

# Amazon ECR Repository for Spring Boot container images
resource "aws_ecr_repository" "inventory_app" {
  name                 = "inventory-app-dev"
  image_tag_mutability = "MUTABLE"
  force_destroy        = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

# IAM Role for CodeBuild
resource "aws_iam_role" "codebuild_role" {
  name = "inventory-codebuild-role-dev"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for CodeBuild
resource "aws_iam_role_policy" "codebuild_policy" {
  name = "inventory-codebuild-policy-dev"
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = aws_ecr_repository.inventory_app.arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject"
        ]
        Resource = [
          aws_s3_bucket.pipeline_artifacts.arn,
          "${aws_s3_bucket.pipeline_artifacts.arn}/*"
        ]
      }
    ]
  })
}

# CodeBuild Project Configuration
resource "aws_codebuild_project" "build" {
  name          = "inventory-app-build-dev"
  description   = "Builds the Spring Boot JAR and ECR Docker container image"
  build_timeout = "10"
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true # Required to run Docker build inside CodeBuild

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = aws_ecr_repository.inventory_app.name
    }
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }
  }

  source {
    type = "CODEPIPELINE"
  }
}

# IAM Role for CodePipeline
resource "aws_iam_role" "codepipeline_role" {
  name = "inventory-codepipeline-role-dev"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for CodePipeline role
resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "inventory-codepipeline-policy-dev"
  role = aws_iam_role.codepipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning",
          "s3:PutObjectAcl",
          "s3:PutObject"
        ]
        Resource = [
          aws_s3_bucket.pipeline_artifacts.arn,
          "${aws_s3_bucket.pipeline_artifacts.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "codestar-connections:UseConnection"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild"
        ]
        Resource = aws_codebuild_project.build.arn
      }
    ]
  })
}

# Get AWS Account Details
data "aws_caller_identity" "current" {}

# AWS CodeStar Connection to GitHub
resource "aws_codestarconnections_connection" "github" {
  name          = "github-connection-dev"
  provider_type = "GitHub"
}

# CodePipeline Definition (GitHub -> CodeBuild -> Jenkins)
resource "aws_codepipeline" "pipeline" {
  name     = "inventory-management-pipeline-dev"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.pipeline_artifacts.bucket
    type     = "S3"
  }

  # Stage 1: Pull source from GitHub
  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.github.arn
        FullRepositoryId = "munashechibaya22/ec2-inventory-springboot-mongodb"
        BranchName       = "main"
      }
    }
  }

  # Stage 2: CodeBuild (Maven & Docker compilation -> ECR Push)
  stage {
    name = "Build"

    action {
      name             = "CodeBuild"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.build.name
      }
    }
  }

  # Stage 3: Jenkins Deploy Trigger
  stage {
    name = "Deploy"

    action {
      name            = "JenkinsDeploy"
      category        = "Build" # CodePipeline groups triggers under build category for Jenkins
      owner           = "Custom"
      provider        = "Jenkins"
      version         = "1"
      input_artifacts = ["build_output"]

      configuration = {
        ProjectName = "Inventory-Management-Deploy" # Jenkins job name
        ServerUrl   = "http://YOUR_JENKINS_EC2_PUBLIC_IP:8080"
      }
    }
  }
}

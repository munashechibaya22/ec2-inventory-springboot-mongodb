# Terraform Modular Infrastructure Configuration (EC2 + Security Groups)

This directory contains the Infrastructure as Code (IaC) configuration for deploying the Spring Boot Inventory Management System to an AWS EC2 instance using the Default VPC.

## 📁 Directory Structure

```text
terraform/
├── modules/                  # Reusable Infrastructure Modules
│   ├── ec2/                  # Provisions Ubuntu EC2 instance, installs Docker & Compose
│   └── security_groups/      # Provisions custom security group rules (Ports 22, 80, 8086, 8080)
└── environments/             # Environment-Specific Deployments
    └── dev/                  # Development Environment config
        ├── main.tf           # Main file querying Default VPC and calling modules
        ├── variables.tf      # Variable declarations
        ├── outputs.tf        # Output bindings (public IP, instance ID)
        ├── terraform.tfvars  # Input values
        └── pipeline.tf       # AWS CodePipeline + Jenkins orchestrations
```

## 🚀 Deployment Guide

To deploy the infrastructure in the development environment:

1. **Prerequisites**:
   * Create an SSH Key Pair on AWS Console and name it.
   * Edit `environments/dev/terraform.tfvars` and set the `key_name` to your AWS SSH key name.

2. **Initialize Terraform**:
   ```bash
   cd terraform/environments/dev
   terraform init
   ```

3. **Plan & Apply Changes**:
   ```bash
   terraform plan
   terraform apply
   ```

4. **CodeStar Connections Configuration**:
   * Once Terraform completes, go to **AWS Console > Developer Tools > Settings > Connections**.
   * Select `github-connection-dev`, click **Update pending connection**, and authorize AWS CodePipeline to access your GitHub repository.

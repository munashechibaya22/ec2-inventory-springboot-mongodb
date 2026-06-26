# 🧩 Spring Boot & MongoDB Inventory Management System (DevOps & IaC Edition)

A secure, modular backend Inventory Management System built with **Java Spring Boot**, **MongoDB**, and **JWT Authentication**. 

This repository has been fully enhanced with modern **Infrastructure as Code (IaC)**, **Docker containerization**, and a **hybrid AWS CodePipeline + Jenkins CI/CD pipeline** for automated cloud deployment.

---

## 🛠️ Technology Stack & Badges
![Java 17](https://img.shields.io/badge/Java-17-orange?style=for-the-badge&logo=openjdk)
![Spring Boot](https://img.shields.io/badge/Spring_Boot-3.2.2-green?style=for-the-badge&logo=springboot)
![MongoDB](https://img.shields.io/badge/MongoDB-Database-emerald?style=for-the-badge&logo=mongodb)
![Docker & Compose](https://img.shields.io/badge/Docker_&_Compose-Orchestration-blue?style=for-the-badge&logo=docker)
![Terraform](https://img.shields.io/badge/Terraform-Infrastructure_as_Code-purple?style=for-the-badge&logo=terraform)
![AWS CodePipeline](https://img.shields.io/badge/AWS_CodePipeline-Orchestration-blue?style=for-the-badge&logo=amazonwebservices)
![Jenkins](https://img.shields.io/badge/Jenkins-CD_Deploy-red?style=for-the-badge&logo=jenkins)

---

## 🏗️ DevOps Deployment Architecture

This project is deployed using a secure, automated hybrid pipeline architecture:

```text
 💻 Local Push (main) 
        │
        ▼
 🐙 GitHub Repository
        │
        ▼
 🔄 AWS CodePipeline (Orchestrator)
        │
        ├──► 🔨 AWS CodeBuild (Build Agent)
        │       ├── Packages Spring Boot JAR (mvnw)
        │       ├── Packages Docker Image
        │       ├── Pushes Container to Amazon ECR
        │       └── Outputs Deploy Artifact (imageDetail.json)
        │
        └──► 🔴 Jenkins Server (Deploy Agent)
                ├── Reads imageDetail.json ECR URI
                ├── SSHs into Ubuntu EC2 host
                ├── Authenticates EC2 Docker engine to AWS ECR
                └── Restarts docker-compose stack (App + Mongo + Nginx)
```

### Key Security & Routing Highlights:
* **Private S3 & ECR Registry:** The application container image is stored in a private Amazon ECR repository.
* **Nginx Reverse Proxy:** Nginx acts as the front gateway on the host, reverse proxying incoming public requests from Port `80` to internal container Port `8086`.
* **Private MongoDB:** MongoDB port `27017` is containerized and restricted inside the Docker network. Database storage is persistent via a Docker volume.

---

## 📁 Repository Directory Map

```text
├── .github/                    # (Optional) GitHub hooks
├── app/                        # Spring Boot source code (Maven layout)
├── buildspec.yml               # AWS CodeBuild task configuration
├── docker-compose.yml          # Container configuration (App + MongoDB + Nginx)
├── Dockerfile                  # Multi-stage Java compile and runtime Docker configuration
├── Jenkinsfile                 # Jenkins CD deployment pipeline stages
├── nginx.conf                  # Nginx reverse proxy routing details
├── docs/
│   ├── AWS_CONSOLE.md          # Manual AWS console provisioning instructions
│   └── JENKINS_SETUP.md        # Detailed Jenkins installation & trigger setup guide
├── scripts/
│   ├── deploy.sh               # Local bash automation deploy script
│   └── deploy.ps1              # Local PowerShell automation deploy script
└── terraform/
    ├── README.md               # Infrastructure deployment guide
    ├── modules/                # Reusable IaC modules
    │   ├── ec2/                # Provisions EC2 Ubuntu instance & installs Docker/Compose
    │   └── security_groups/    # Security rules (SSH, HTTP, Jenkins dashboard)
    └── environments/
        └── dev/                # Dev environment values & CodePipeline config (pipeline.tf)
```

---

## 🚀 Environments & Local Configuration

### Local Development Setup:
The project uses `.env` environment variables to override values in `src/main/resources/application.properties` dynamically.
1. Copy the example environment variables:
   ```bash
   cp .env.example .env
   ```
2. Build and run the local container stack:
   ```bash
   docker compose up -d
   ```
   The backend will be available at `http://localhost:80` (routed via Nginx to the Java backend).

---

## 🏗️ Managing Infrastructure with Terraform

The infrastructure defaults to deploying inside AWS's **Default VPC** and public default subnets.

To deploy:
1. Generate an AWS SSH Key Pair and input its name in `terraform/environments/dev/terraform.tfvars`.
2. Execute the Terraform stack:
   ```bash
   cd terraform/environments/dev
   terraform init
   terraform plan
   terraform apply
   ```

---

## 🔄 Setup CI/CD Pipeline
For detailed step-by-step instructions on setting up AWS resources manually and linking Jenkins triggers, see:
* **[AWS Web Console Setup Guide](docs/AWS_CONSOLE.md)**
* **[Jenkins Server Configuration Guide](docs/JENKINS_SETUP.md)**

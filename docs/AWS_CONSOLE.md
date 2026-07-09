# Stage 1: AWS Console Guide (Manual Setup)

This guide walks you through manually provisioning and configuring the complete AWS infrastructure for the Spring Boot + MongoDB + Nginx application using the AWS Web Console.

---

## Step 1: Create the AWS SSH Key Pair
You need an SSH key pair to access the EC2 instance.
1. Open the **Amazon EC2 console** at [https://console.aws.amazon.com/ec2/](https://console.aws.amazon.com/ec2/).
2. In the left navigation pane under **Network & Security**, click **Key Pairs**.
3. Click **Create key pair**.
4. Configure the settings:
   * **Name**: Enter `inventory-app-key`.
   * **Key pair type**: Choose **RSA**.
   * **Private key file format**: Choose **.pem**.
5. Click **Create key pair** and download the key. Save it securely.

---

## Step 2: Create the Security Group
Create a security group to control traffic to the EC2 instance.
1. In the EC2 console left navigation pane under **Network & Security**, click **Security Groups**.
2. Click **Create security group**.
3. Configure settings:
   * **Security group name**: `inventory-app-sg`.
   * **Description**: `SG for Spring Boot Inventory Application`.
   * **VPC**: Select your **Default VPC** (usually pre-selected).
4. Under **Inbound rules**, add the following:
   * **Rule 1 (SSH)**: Type: **SSH** | Port: `22` | Source: **Anywhere-IPv4** (`0.0.0.0/0`) or your IP.
   * **Rule 2 (HTTP)**: Type: **HTTP** | Port: `80` | Source: **Anywhere-IPv4** (`0.0.0.0/0`).
   * **Rule 3 (App Direct)**: Type: **Custom TCP** | Port: `8086` | Source: **Anywhere-IPv4** (`0.0.0.0/0`).
   * **Rule 4 (Jenkins)**: Type: **Custom TCP** | Port: `8080` | Source: **Anywhere-IPv4** (`0.0.0.0/0`).
5. Click **Create security group**.

---

## Step 3: Provision the EC2 Instance
1. In the EC2 console, click **Instances** in the left sidebar, and click **Launch instances**.
2. Configure settings:
   * **Name**: `inventory-app-server`.
   * **OS Image (AMI)**: Choose **Ubuntu** ➔ Select **Ubuntu Server 22.04 LTS (HVM)**.
   * **Instance Type**: Select **t3.micro** (free tier in Sweden/eu-north-1) or **t3.small** (recommended: Spring Boot + MongoDB run better on 2GB RAM).
   * **Key Pair**: Select the `inventory-app-key` you created.
   * **Network Settings**: 
     * Click **Edit**.
     * **Subnet**: Select any default public subnet.
     * **Auto-assign public IP**: Set to **Enable**.
     * **Firewall (security groups)**: Choose **Select existing security group** and select `inventory-app-sg`.
3. Scroll down, expand **Advanced Details**, scroll to **User data** at the bottom, and paste this script to auto-install Docker on startup:
   ```bash
   #!/bin/bash
   sudo apt-get update -y
   sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
   sudo install -m 0755 -d /etc/apt/keyrings
   sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
   sudo chmod a+r /etc/apt/keyrings/docker.asc
   echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
   sudo apt-get update -y
   sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
   sudo systemctl start docker
   sudo systemctl enable docker
   sudo usermod -aG docker ubuntu
   ```
4. Click **Launch instance**. Once running, note its **Public IPv4 address**.

---

## Step 4: Create the Amazon ECR Repository
Create a registry to store your build container images.
1. Open the **Amazon ECR console** at [https://console.aws.amazon.com/ecr/](https://console.aws.amazon.com/ecr/).
2. Click **Create repository**.
3. Configure settings:
   * **Visibility settings**: Choose **Private**.
   * **Repository name**: Enter `inventory-app-dev`.
4. Click **Create repository**. Copy the **URI** (e.g., `123456789012.dkr.ecr.eu-north-1.amazonaws.com/inventory-app-dev`).

---

## Step 5: Configure IAM Roles for CodeBuild
CodeBuild needs access to push images to ECR and write logs to CloudWatch.
1. Open the **IAM Console** at [https://console.aws.amazon.com/iam/](https://console.aws.amazon.com/iam/).
2. Click **Roles** ➔ **Create role**.
3. Select **AWS Service** ➔ Choose **CodeBuild** as the service.
4. Search and attach these policies:
   * `AmazonEC2ContainerRegistryPowerUser` (Allows logging in and pushing Docker images).
   * `CloudWatchLogsFullAccess` (Allows writing build logs).
5. Name the role: `inventory-codebuild-role`.
6. Click **Create role**.

---

## Step 6: Create the AWS CodeBuild Project
1. Open the **AWS CodeBuild console** at [https://console.aws.amazon.com/codebuild/](https://console.aws.amazon.com/codebuild/).
2. Click **Create build project**.
3. Configure settings:
   * **Project name**: `inventory-app-build-dev`.
   * **Source**: Choose **GitHub** ➔ Authorize connection to your account ➔ Select **Repository in my GitHub account** ➔ Select `ec2-inventory-springboot-mongodb`.
   * **Environment**:
     * **Environment image**: **Managed image**.
     * **Operating system**: **Ubuntu**.
     * **Runtime(s)**: **Standard**.
     * **Image**: Select the latest standard image (e.g. `aws/codebuild/standard:7.0`).
     * **Privileged**: Check **"Enable this flag if you want to build Docker images..."** (CRITICAL).
     * **Service role**: Choose **Existing service role** and select `inventory-codebuild-role`.
     * Expand **Additional configuration** and add these Environment Variables:
       * `AWS_ACCOUNT_ID` = `YOUR_AWS_ACCOUNT_NUMBER`
       * `IMAGE_REPO_NAME` = `inventory-app-dev`
   * **Buildspec**: Choose **Use a buildspec file** (it will auto-detect the `buildspec.yml` in the root of the project).
4. Click **Create build project**.

---

## Step 7: Create the AWS CodePipeline
Create the pipeline to tie everything together.
1. Open the **AWS CodePipeline console** at [https://console.aws.amazon.com/codepipeline/](https://console.aws.amazon.com/codepipeline/).
2. Click **Create pipeline**.
3. **Choose pipeline settings**:
   * **Pipeline name**: `inventory-management-pipeline-dev`.
   * **Service role**: Choose **New service role**.
4. **Add source stage**:
   * **Source provider**: **GitHub (Version 2)**.
   * **Connection**: Click **Connect to GitHub** ➔ Name connection `github-connection` ➔ Install App/Authorize ➔ Click Connect.
   * **Repository name**: `YOUR_GITHUB_USERNAME/ec2-inventory-springboot-mongodb`.
   * **Branch name**: `main`.
   * **Output artifact format**: Choose **CodePipeline default**.
5. **Add build stage**:
   * **Build provider**: **AWS CodeBuild**.
   * **Region**: Select your active region.
   * **Project name**: Select `inventory-app-build-dev`.
   * **Build type**: Single build.
6. **Add deploy stage**:
   * *Skip deploy stage* for now (AWS CodePipeline doesn't natively have a single-click EC2 SSH deploy. We configure the Jenkins integration in Step 8 to pull the build artifact and handle deployment).
7. Review and click **Create pipeline**.

---

## Step 8: Complete Jenkins Integration
Follow [docs/JENKINS_SETUP.md](JENKINS_SETUP.md) to install Jenkins on your EC2 instance, set up credentials, and create the deployment job triggered by CodePipeline.

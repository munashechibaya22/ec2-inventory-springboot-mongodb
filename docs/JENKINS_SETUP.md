# Jenkins Server Installation & Configuration Guide

This guide walks you through setting up Jenkins on the newly provisioned Ubuntu EC2 instance, installing required plugins, and integrating it with AWS CodePipeline.

---

## Prerequisites: Configure EC2 Instance IAM Role
To allow Jenkins on your EC2 instance to communicate with AWS CodePipeline and ECR securely without hardcoding credentials:
1. Open the **AWS IAM Console** > **Roles** > **Create role**.
2. Select **AWS Service** as the trusted entity and **EC2** as the use case.
3. Search for and attach the following two standard AWS Managed Policies:
   * **`AWSCodePipelineCustomActionAccess`**: Allows Jenkins to poll CodePipeline and download build artifacts from S3.
   * **`AmazonEC2ContainerRegistryReadOnly`**: Allows the instance to pull your private Docker images from ECR during deployment.
4. Name the role (e.g., `Jenkins-EC2-Role`) and click **Create role**.
5. Open the **Amazon EC2 console**, select your Jenkins EC2 instance, and choose **Actions > Security > Modify IAM role**.
6. Select the `Jenkins-EC2-Role` you created and click **Update IAM role**.

---

## Step 1: Install Java and Jenkins on the Server
SSH into your EC2 instance (`ssh -i your-key.pem ubuntu@YOUR_EC2_IP`) and execute these commands:

```bash
# Update package lists
sudo apt-get update -y

# Install OpenJDK 21 (Required by Jenkins)
sudo apt-get install openjdk-21-jdk -y

# Install AWS CLI (Required to authenticate with ECR)
sudo apt-get install awscli -y

# Add the Jenkins GPG key and Repository
sudo mkdir -p /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key

echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/" | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update and install Jenkins
sudo apt-get update -y
sudo apt-get install jenkins -y

# Allow jenkins user to execute local docker commands
sudo usermod -aG docker jenkins

# Start and enable Jenkins service
sudo systemctl enable jenkins
sudo systemctl start jenkins
```

---

## Step 2: Unlock Jenkins Dashboard
1. Open your web browser and navigate to `http://YOUR_EC2_IP:8080` (ensure Port `8080` is open in your EC2 Security Group).
2. Retrieve the initial admin password from the EC2 terminal:
   ```bash
   sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   ```
3. Copy the password, paste it into the dashboard, and select **Install suggested plugins**.
4. Create your admin user account and complete the setup.

---

## Step 3: Install Required Plugins
To support CodePipeline deployments, install the following plugin:
1. Go to **Manage Jenkins > Plugins > Available Plugins**.
2. Search and install:
   * **AWS CodePipeline Plugin**: Integrates Jenkins jobs as custom build/deploy actions in AWS CodePipeline.
3. Click **Install without restart** and check the box to restart Jenkins when done.

---

## Step 4: Configure Credentials (Optional)
If you attached the IAM Instance Profile (`Jenkins-EC2-Role`) to your EC2 instance in the Prerequisites step, **you can skip this step entirely**. The AWS SDK will automatically authenticate.

---

## Step 5: Configure Jenkins Freestyle Project
Create the deployment job:
1. From the Jenkins dashboard, click **New Item**.
2. Enter name: `Inventory-Management-Deploy` (Must match the **Project name** value you configure in the AWS CodePipeline Jenkins action).
3. Select **Freestyle project** and click **OK**.
4. Under **Source Code Management**:
   * Select **AWS CodePipeline**.
   * **AWS Region**: Select your active AWS region (e.g., `eu-north-1` or `us-east-1`).
   * **AWS Credentials**: Leave blank (relying on the EC2 IAM Instance Profile).
   * **Clear Workspace**: Check this box.
   * **Category** (CodePipeline Action Type): Select **Build**.
5. Under **Build Triggers**:
   * Check **Poll SCM** and set schedule to `H/2 * * * *` (polls CodePipeline every 2 minutes).
6. Under **Build Steps**:
   * Click **Add build step** and choose **Execute shell**.
   * Paste the following script:
     ```bash
     # 1. Read ECR Image URI from CodeBuild output artifact
     export ECR_IMAGE_URI=$(python3 -c "import json; print(json.load(open('imageDetail.json'))['ImageURI'])")
     echo "Deploying image: $ECR_IMAGE_URI"

     # 2. Authenticate local Docker engine to AWS ECR
     aws ecr get-login-password --region eu-north-1 | docker login --username AWS --password-stdin $(echo $ECR_IMAGE_URI | cut -d'/' -f1)

     # 3. Pull and restart the application stack locally
     docker pull $ECR_IMAGE_URI
     export ECR_IMAGE_URI=$ECR_IMAGE_URI
     docker compose down --remove-orphans || true
     docker compose up -d
     ```
7. Click **Save**.

---

## Step 6: Integrate Jenkins into AWS CodePipeline
Since you did not use Terraform, you must link your Jenkins server to your CodePipeline in the AWS Console:
1. Open the **AWS CodePipeline console** and click on your pipeline `inventory-management-pipeline-dev`.
2. Click **Edit** in the top right.
3. Scroll to the bottom of the pipeline and click **+ Add stage**. Name this stage `Deploy`.
4. In the new `Deploy` stage, click **+ Add action group**.
5. Configure the action:
    * **Action name**: `JenkinsDeploy`
    * **Input artifacts**: Select `OutputArtifact` (the output from the CodeBuild stage).
    * **Provider name**: `Jenkins` (this is the default name of the provider defined in **Manage Jenkins > System > AWS CodePipeline**).
    * **Server URL**: `http://<YOUR_EC2_PUBLIC_IP>:8080` (The public IP of your EC2 instance running Jenkins).
    * **Project name**: `Inventory-Management-Deploy` (the exact name of the Pipeline job you created in Jenkins).
6. Click **Done** and then **Save** in the top right of the pipeline editor.

---

## Troubleshooting: GzipCompressorInputStream ClassNotFoundException
If your Jenkins build fails with a `java.lang.NoClassDefFoundError: org/apache/commons/compress/compressors/gzip/GzipCompressorInputStream` error:
1. SSH into your EC2 instance.
2. Download the missing JAR file directly into the plugin's private library directory and assign ownership to the `jenkins` user:
   ```bash
   sudo wget -O /var/lib/jenkins/plugins/aws-codepipeline/WEB-INF/lib/commons-compress-1.26.0.jar \
     https://repo1.maven.org/maven2/org/apache/commons/commons-compress/1.26.0/commons-compress-1.26.0.jar
   sudo chown jenkins:jenkins /var/lib/jenkins/plugins/aws-codepipeline/WEB-INF/lib/commons-compress-1.26.0.jar
   sudo systemctl restart jenkins
   ```
3. Once Jenkins restarts, release the changes again in AWS CodePipeline.


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
To support CodePipeline and SSH deployments, install the following plugins:
1. Go to **Manage Jenkins > Plugins > Available Plugins**.
2. Search and install:
   * **AWS CodePipeline Plugin**: Integrates Jenkins jobs as custom build/deploy actions in AWS CodePipeline.
   * **SSH Agent Plugin**: Allows Jenkins jobs to execute secure shell commands on target servers.
3. Click **Install without restart** and check the box to restart Jenkins when done.

---

## Step 4: Configure Credentials
Add the EC2 SSH private key to Jenkins so the build executor can deploy to the host:
1. Go to **Manage Jenkins > Credentials > System > Global credentials > Add Credentials**.
2. Configure:
   * **Kind**: SSH Username with private key.
   * **Scope**: Global.
   * **ID**: `ec2-ssh-key` (Must match the `SSH_CRED_ID` variable in the `Jenkinsfile`).
   * **Username**: `ubuntu`
   * **Private Key**: Select **Enter directly**, click **Add**, and paste the complete content of your downloaded private key (`.pem` file).
3. Click **Create**.

---

## Step 5: Configure Jenkins Pipeline Project
Create the build job to connect to the repository:
1. From the Jenkins dashboard, click **New Item**.
2. Enter name: `Inventory-Management-Deploy` (Must match the **Project name** value you configure in the AWS CodePipeline Jenkins action).
3. Select **Pipeline** and click **OK**.
4. Under **Build Triggers**, check **Poll SCM** and set schedule to `* * * * *` (polls AWS CodePipeline every minute) or `H/2 * * * *` (every 2 minutes).
5. Under **Pipeline**:
   * **Definition**: Pipeline script from SCM.
   * **SCM**: Select **AWS CodePipeline**.
   * **AWS Region**: Select your active AWS region (e.g., `eu-north-1` or `us-east-1`).
   * **AWS Credentials**: Leave blank (if your EC2 instance has an IAM Role with CodePipeline access attached) or select your AWS credentials.
   * **Clear Workspace**: Check this box.
   * **Category** (CodePipeline Action Type): Select **Build** (this must match the action type in AWS CodePipeline).
   * **Script Path**: `Jenkinsfile`
6. Click **Save**.

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


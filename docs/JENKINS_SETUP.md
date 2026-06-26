# Jenkins Server Installation & Configuration Guide

This guide walks you through setting up Jenkins on the newly provisioned Ubuntu EC2 instance, installing required plugins, and integrating it with AWS CodePipeline.

---

## Step 1: Install Java and Jenkins on the Server
SSH into your EC2 instance (`ssh -i your-key.pem ubuntu@YOUR_EC2_IP`) and execute these commands:

```bash
# Update package lists
sudo apt-get update -y

# Install OpenJDK 17 (Required by Jenkins & Spring Boot)
sudo apt-get install openjdk-17-jdk -y

# Add the Jenkins GPG key and Repository
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
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
2. Enter name: `Inventory-Management-Build` (Must match the `ProjectName` parameter in `pipeline.tf`).
3. Select **Pipeline** and click **OK**.
4. Under **Build Triggers**, check **AWS CodePipeline**.
5. Under **Pipeline**:
   * **Definition**: Pipeline script from SCM.
   * **SCM**: Git.
   * **Repository URL**: `https://github.com/YOUR_GITHUB_USERNAME/ec2-inventory-springboot-mongodb.git`
   * **Branch Specifier**: `*/main`
   * **Script Path**: `Jenkinsfile`
6. Click **Save**.

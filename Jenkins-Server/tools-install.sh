#!/bin/bash
# Ubuntu 22.04 - Jenkins Server

set -e

echo "=============================="
echo " INSTALL JENKINS SERVER"
echo "=============================="

# Install Java
echo "[1/7] Install Java..."
sudo apt update -y
sudo apt install -y openjdk-21-jre
java --version

# Install Jenkins
echo "[2/7] Install Jenkins..."
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | \
  sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install -y jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins
echo "Jenkins status: $(sudo systemctl is-active jenkins)"

# Install Docker
echo "[3/7] Install Docker..."
sudo apt install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
  https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt install -y docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker jenkins
sudo usermod -aG docker ubuntu
sudo systemctl enable docker
sudo systemctl restart docker
sudo chmod 777 /var/run/docker.sock
echo "Docker status: $(sudo systemctl is-active docker)"

# Install Terraform
echo "[4/7] Install Terraform..."
sudo apt install -y unzip gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | \
  gpg --dearmor | \
  sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
  https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
  sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt install -y terraform
terraform --version

# Install Kubectl
echo "[5/7] Install Kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm -f kubectl kubectl.sha256
kubectl version --client

# Install AWS CLI
echo "[6/7] Install AWS CLI..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf aws awscliv2.zip
aws --version

# Install Trivy
echo "[7/7] Install Trivy..."
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | \
  gpg --dearmor | \
  sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
sudo rm -f /etc/apt/sources.list.d/trivy.list
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | \
  sudo tee /etc/apt/sources.list.d/trivy.list
sudo apt-get install -y trivy
trivy --version

echo ""
echo "=============================="
echo " SEMUA TOOLS BERHASIL DIINSTALL"
echo "=============================="
echo "Java      : $(java --version 2>&1 | head -1)"
echo "Jenkins   : $(sudo systemctl is-active jenkins)"
echo "Docker    : $(docker --version)"
echo "Terraform : $(terraform --version | head -1)"
echo "Kubectl   : $(kubectl version --client --short 2>/dev/null || kubectl version --client)"
echo "AWS CLI   : $(aws --version)"
echo "Trivy     : $(trivy --version)"

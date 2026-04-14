#!/bin/bash
# Ubuntu 22.04
# Uninstall semua tools lalu install ulang dari awal

set -e

echo "=============================="
echo " UNINSTALL SEMUA TOOLS"
echo "=============================="

# Stop services
sudo systemctl stop jenkins 2>/dev/null || true
sudo systemctl stop docker 2>/dev/null || true

# Uninstall Jenkins
echo "[1/8] Uninstall Jenkins..."
sudo apt remove --purge -y jenkins 2>/dev/null || true
sudo rm -f /etc/apt/sources.list.d/jenkins.list
sudo rm -f /etc/apt/keyrings/jenkins-keyring.asc
sudo rm -rf /var/lib/jenkins
sudo rm -rf /var/cache/jenkins
sudo rm -rf /var/log/jenkins

# Uninstall Docker
echo "[2/8] Uninstall Docker..."
sudo docker rm -f $(sudo docker ps -aq) 2>/dev/null || true
sudo docker rmi -f $(sudo docker images -q) 2>/dev/null || true
sudo apt remove --purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker.io 2>/dev/null || true
sudo rm -f /etc/apt/sources.list.d/docker.list
sudo rm -f /etc/apt/keyrings/docker.asc
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd

# Uninstall Java
echo "[3/8] Uninstall Java..."
sudo apt remove --purge -y openjdk-21-jre 2>/dev/null || true

# Uninstall Terraform
echo "[4/8] Uninstall Terraform..."
sudo apt remove --purge -y terraform 2>/dev/null || true
sudo rm -f /etc/apt/sources.list.d/hashicorp.list
sudo rm -f /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Uninstall Kubectl
echo "[5/8] Uninstall Kubectl..."
sudo rm -f /usr/local/bin/kubectl
rm -f kubectl kubectl.sha256

# Uninstall AWS CLI
echo "[6/8] Uninstall AWS CLI..."
sudo /usr/local/aws-cli/v2/current/bin/aws --version 2>/dev/null || true
sudo rm -rf /usr/local/aws-cli
sudo rm -f /usr/local/bin/aws
sudo rm -f /usr/local/bin/aws_completer
rm -rf aws awscliv2.zip

# Uninstall Trivy
echo "[7/8] Uninstall Trivy..."
sudo apt remove --purge -y trivy 2>/dev/null || true
sudo rm -f /etc/apt/sources.list.d/trivy.list
sudo rm -f /usr/share/keyrings/trivy.gpg

# Cleanup
echo "[8/8] Cleanup..."
sudo apt autoremove -y
sudo apt autoclean -y
sudo apt update -y

echo ""
echo "=============================="
echo " INSTALL ULANG SEMUA TOOLS"
echo "=============================="

# Install Java
echo "[1/8] Install Java..."
sudo apt install -y openjdk-21-jre
java --version

# Install Jenkins
echo "[2/8] Install Jenkins..."
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install jenkins

# Install Docker
echo "[3/8] Install Docker..."
# Add Docker's official GPG key:
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update

#install Docker
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  sudo systemctl start docker
  sudo systemctl status docker

# Run SonarQube
echo "[4/8] Run SonarQube container..."
sudo docker run -d --name sonarqube -p 9000:9000 sonarqube:community

# Install Terraform
echo "[5/8] Install Terraform..."
sudo apt install -y unzip gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | \
  gpg --dearmor | \
  sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
  https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
  sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt install -y terraform
terraform --version

# Install Kubectl
echo "[6/8] Install Kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm -f kubectl kubectl.sha256
kubectl version --client

# Install AWS CLI
echo "[7/8] Install AWS CLI..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf aws awscliv2.zip
aws --version

# Install Trivy
echo "[8/8] Install Trivy..."
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | \
  gpg --dearmor | \
  sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
sudo rm -f /etc/apt/sources.list.d/trivy.list
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | \
  sudo tee /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install -y trivy
trivy --version

echo ""
echo "=============================="
echo " SEMUA TOOLS BERHASIL DIINSTALL"
echo "=============================="
echo "Java    : $(java --version 2>&1 | head -1)"
echo "Jenkins : $(sudo systemctl is-active jenkins)"
echo "Docker  : $(docker --version)"
echo "Terraform: $(terraform --version | head -1)"
echo "Kubectl : $(kubectl version --client --short 2>/dev/null || kubectl version --client)"
echo "AWS CLI : $(aws --version)"
echo "Trivy   : $(trivy --version)"

#!/bin/bash
# Ubuntu 22.04 - SonarQube Server

set -e

echo "=============================="
echo " INSTALL SONARQUBE SERVER"
echo "=============================="

# Install Docker
echo "[1/2] Install Docker..."
sudo apt update -y
sudo apt install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
  https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker ubuntu
sudo systemctl enable docker
sudo systemctl start docker

# Run SonarQube
echo "[2/2] Run SonarQube container..."
sudo docker run -d \
  --name sonarqube \
  --restart always \
  -p 9000:9000 \
  sonarqube:community

echo ""
echo "=============================="
echo " SONARQUBE BERHASIL DIINSTALL"
echo "=============================="
echo "Docker  : $(docker --version)"
echo "SonarQube bisa diakses di: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):9000"

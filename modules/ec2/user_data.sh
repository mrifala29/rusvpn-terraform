#!/bin/bash
set -e

# Update package lists
apt-get update -y

# Install prerequisites
apt-get install -y apt-transport-https ca-certificates curl software-properties-common git

# Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up the stable repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io

# Install Docker Compose (V2 plugin)
apt-get install -y docker-compose-plugin

# Enable and start Docker
systemctl enable docker
systemctl start docker

# Add ubuntu user to docker group
usermod -aG docker ubuntu

# Prepare directory for openvpn service
mkdir -p /opt/rusvpn
chown -R ubuntu:ubuntu /opt/rusvpn

echo "Docker and Docker Compose installation complete. Server is ready for OpenVPN deployment."

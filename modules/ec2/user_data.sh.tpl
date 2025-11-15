#!/bin/bash

# Log
set -xeo pipefail

USERDATA_LOG_FILE=/var/log/user_data.log
exec > >(tee $USERDATA_LOG_FILE | logger -t user-data -s 2>/dev/console) 2>&1
#exec > >(tee $USERDATA_LOG_FILE | logger -t user-data ) 2>&1
echo "KYC_EC2_USERDATA_LOG_FILE=$USERDATA_LOG_FILE" >> /etc/environment

# ENV variables
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
EC2_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
EC2_NAME=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/tags/instance/Name)
hostnamectl set-hostname "$EC2_NAME"
PRIVATE_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/local-ipv4)

echo "KYC_EC2_METADATA_TOKEN=$TOKEN" >> /etc/environment
echo "KYC_EC2_ID=$EC2_ID" >> /etc/environment
echo "KYC_EC2_NAME=$EC2_NAME" >> /etc/environment
echo "KYC_PRIVATE_IP=$PRIVATE_IP" >> /etc/environment

# Check internet
while true; do
  if ping -c 1 -W 1 8.8.8.8 >/dev/null 2>&1; then
    break
  else 
    sleep 3
  fi
done

# Install packages
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get -y install unzip ca-certificates curl make

# Install awscli 
curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# Install docker
sudo apt-get install -y gnupg lsb-release

sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null	

sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
#sudo groupadd docker
sudo usermod -aG docker ubuntu
#echo 'newgrp docker' >> /home/ubuntu/.bashrc
sudo systemctl enable docker
sudo systemctl start docker
# ECR Credentials (uncomment and configure with your AWS Account ID)
# Replace YOUR_AWS_ACCOUNT_ID with your actual AWS Account ID
#sudo -u ubuntu bash <<'EOF'
#REGION="us-east-1"
#AWS_ACCOUNT_ID="YOUR_AWS_ACCOUNT_ID"
#ECR_URL="${AWS_ACCOUNT_ID}.dkr.ecr.$REGION.amazonaws.com"
#
#aws ecr get-login-password --region "$REGION" \
#  | docker login --username AWS --password-stdin "$ECR_URL"
#EOF

# EFS
%{ if efs_enable }
sudo apt-get -y install nfs-common
sudo mkdir -p ${efs_dir}
sudo mount -t nfs4 -o nfsvers=4.1 ${efs_dns_name}:/ ${efs_dir}
sudo sh -c 'echo "${efs_dns_name}:/ ${efs_dir} nfs4 defaults,_netdev 0 0" >> /etc/fstab'
%{ endif }

echo "=== SCRIPT FINISHED SUCCESSFULLY ==="

#!/bin/bash

# Log
set -xeo pipefail

USERDATA_LOG_FILE=/var/log/user_data.log
exec > >(tee $USERDATA_LOG_FILE | logger -t user-data -s 2>/dev/console) 2>&1
echo "KYC_EC2_USERDATA_LOG_FILE=$USERDATA_LOG_FILE" >> /etc/environment


# ENV variables
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
EC2_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
EC2_NAME=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/tags/instance/Name)
hostnamectl set-hostname "$EC2_NAME"
PRIVATE_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/local-ipv4)
PUBLIC_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4)

echo "KYC_EC2_METADATA_TOKEN=$TOKEN" >> /etc/environment
echo "KYC_EC2_ID=$EC2_ID" >> /etc/environment
echo "KYC_EC2_NAME=$EC2_NAME" >> /etc/environment
echo "KYC_PRIVATE_IP=$PRIVATE_IP" >> /etc/environment
echo "KYC_PUBLIC_IP=$PUBLIC_IP" >> /etc/environment

# Install packages
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get -y install unzip curl


# Intall pritunl
echo "deb [signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/8.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-8.0.list

echo "deb [signed-by=/usr/share/keyrings/openvpn-repo.gpg] https://build.openvpn.net/debian/openvpn/stable noble main" | tee /etc/apt/sources.list.d/openvpn.list


echo "deb [signed-by=/usr/share/keyrings/pritunl.gpg] https://repo.pritunl.com/stable/apt noble main" | tee /etc/apt/sources.list.d/pritunl.list

sudo apt --assume-yes install gnupg

curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor --yes
curl -fsSL https://swupdate.openvpn.net/repos/repo-public.gpg | sudo gpg -o /usr/share/keyrings/openvpn-repo.gpg --dearmor --yes
curl -fsSL https://raw.githubusercontent.com/pritunl/pgp/master/pritunl_repo_pub.asc | sudo gpg -o /usr/share/keyrings/pritunl.gpg --dearmor --yes

sudo apt update
sudo apt --assume-yes install pritunl openvpn mongodb-org wireguard wireguard-tools

sudo ufw disable

sudo sh -c 'echo "* hard nofile 64000" >> /etc/security/limits.conf'
sudo sh -c 'echo "* soft nofile 64000" >> /etc/security/limits.conf'
sudo sh -c 'echo "root hard nofile 64000" >> /etc/security/limits.conf'
sudo sh -c 'echo "root soft nofile 64000" >> /etc/security/limits.conf'

sudo systemctl start pritunl mongod
sudo systemctl enable pritunl mongod

SETUP_KEY=$(sudo pritunl setup-key)

sudo tee /etc/pritunl.conf <<EOF
{
    "static_cache": true,
    "bind_addr": "0.0.0.0",
    "port": 443,
    "log_path": "/var/log/pritunl.log",
    "www_path": "/usr/share/pritunl/www",
    "temp_path": "/tmp/pritunl_%r",
    "mongodb_uri": "mongodb://localhost:27017/pritunl",
    "local_address_interface": "auto"
}
EOF

sleep 5
sudo pritunl set-mongodb "mongodb://localhost:27017/pritunl"

ADMIN_USER=$(sudo pritunl default-password | grep 'username:' | awk -F'"' '{print $2}')
ADMIN_PSW=$(sudo pritunl default-password | grep 'password:' | awk -F'"' '{print $2}' | tr -d '\n')
echo "VPN_PRITUNL_ADMIN_USER=$ADMIN_USER" >> /etc/environment
echo "VPN_PRITUNL_ADMIN_PSW=$ADMIN_PSW" >> /etc/environment
echo "VPN_PRITUNL_PORT=14793" >> /etc/environment

sudo systemctl restart pritunl


echo "=== SCRIPT FINISHED SUCCESSFULLY ==="

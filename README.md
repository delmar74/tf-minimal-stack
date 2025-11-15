# Minimal AWS Infrastructure Stack

Terraform configuration for deploying a minimal AWS infrastructure stack including VPC, EC2 instances, RDS database, EFS storage, and VPN server.

## Structure

```
├── environment
│   ├── data.tf
│   ├── ec2.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── terraform.tfvars.example
│   └── variables.tf
├── modules
│   ├── ec2        # EC2 instances
│   ├── efs        # shared storage
│   ├── key        # key pairs
│   ├── rds        # RDS database
│   ├── vpc        # network
│   └── vpn        # pritunl VPN server
```

## Setup

### Prerequisites

- Terraform >= 1.0
- AWS CLI configured with appropriate credentials
- AWS Account with necessary permissions

### Configuration

1. Navigate to the environment directory:
```sh
cd environment
```

2. Copy the example configuration file:
```sh
cp terraform.tfvars.example terraform.tfvars
```

3. Edit `terraform.tfvars` with your values:
   - AWS region
   - VPC CIDR blocks
   - RDS credentials
   - Project tags
   - EC2 instance configurations

4. Initialize Terraform:
```sh
terraform init
```

5. Review the plan:
```sh
terraform plan
```

6. Apply the configuration:
```sh
terraform apply
```

## Outputs

After applying, you can retrieve important information:

```sh
# Get SSH private key
terraform output -raw key_private_pem > key.pem
chmod 400 key.pem

# Get FastAPI application URL
terraform output fastapi_url

# Get VPN server public IP
terraform output vpn_public_ip

# Get RDS endpoint
terraform output rds_endpoint
```

## Components

### VPC
- Public and private subnets
- Internet Gateway
- NAT Gateway
- Route tables

### EC2 Instances
- FastAPI application server
- Auto-configured with database connection
- User data scripts for automatic setup

### RDS
- MySQL database instance
- Private subnet deployment
- Automatic database initialization

### EFS
- Shared file storage
- Mountable on EC2 instances

### VPN Server (Pritunl)
- VPN server for secure access
- Admin web interface

## VPN Configuration

1. Connect to VPN server by SSH using public IP:
```sh
ssh -i key.pem ubuntu@$(terraform output -raw vpn_public_ip)
```

2. Get default password:
```sh
sudo pritunl default-password
# Administrator default password will be displayed
#   username: "pritunl"
#   password: "<get from server output>"
```

3. Configure VPN server:
   - Add organization (Users > Add organization)
   - Add server (Servers > Add server)
     - Port: 14793/udp
   - Attach organization (Servers > Attach organization)
   - Run server (Servers > Start server)
   - Add user (Users > Add user)

## FastAPI Application

The FastAPI application is automatically deployed on EC2 instances configured with `use_fastapi = true`. It:
- Connects to RDS MySQL database
- Displays data from `table1` in a web interface
- Automatically initializes the database with sample data

Access the application via the `fastapi_url` output.

## Security Notes

- Never commit `terraform.tfvars` files (they contain sensitive data)
- Private keys are generated automatically and should be kept secure
- RDS passwords should be strong and unique
- Review security group rules before production use

## License

[Add your license here]

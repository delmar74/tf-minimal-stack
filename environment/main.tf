### GENERAL
provider "aws" {
  region = var.aws_region
}

### NETWORK
module "vpc" {
  source = "../modules/vpc"

  vpc_cidr             = var.vpc_cidr
  public_subnet_cidr   = var.vpc_public_subnet_cidr
  private_subnet_cidr  = var.vpc_private_subnet_cidr

  vpc_name             = "${lower(var.tags["Project"])}-vpc"
  public_subnet_name   = "${lower(var.tags["Project"])}-public-subnet"
  private_subnet_name  = "${lower(var.tags["Project"])}-private-subnet"

  availability_zone    = data.aws_availability_zones.available.names[0] 

  igw_name             = "${lower(var.tags["Project"])}-igw"
  nat_name             = "${lower(var.tags["Project"])}-nat"
  public_rt_name       = "${lower(var.tags["Project"])}-public-rt"
  private_rt_name      = "${lower(var.tags["Project"])}-private-rt"

  tags = var.tags
}

### KEY PAIR
module "key" {
  source            = "../modules/key"
  tags              = var.tags
}

### EFS
module "efs" {
  source            = "../modules/efs"
  vpc_id            = module.vpc.vpc_id
  subnet_id         = module.vpc.private_subnet_id
  tags              = var.tags
}



### VPN
module "vpn" {
  source         = "../modules/vpn"

  ami_id         = data.aws_ami.ubuntu_24_04.id
  instance_type  = var.vpn_ec2_type
  key_name       = module.key.key_name

  vpc_id         = module.vpc.vpc_id
  subnet_id      = module.vpc.public_subnet_id
  volume_size    = var.vpn_ec2_volume_size
  admin_port     = var.vpn_admin_port

  tags          = var.tags
}

### Additional Private Subnet for RDS (in different AZ - required by AWS)
resource "aws_subnet" "private_rds" {
  vpc_id            = module.vpc.vpc_id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 3)  # 10.20.3.0/24
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = merge(
    var.tags,
    {
      Name = "${lower(var.tags["Project"])}-private-rds-subnet"
    }
  )
}

### RDS
module "rds" {
  source = "../modules/rds"

  vpc_id                     = module.vpc.vpc_id
  vpc_cidr                   = module.vpc.vpc_cidr
  subnet_ids                 = [module.vpc.private_subnet_id, aws_subnet.private_rds.id]  # Two subnets in different AZs (AWS requirement)
  allowed_security_group_ids = []  # Will allow from VPC CIDR instead to avoid circular dependency

  db_identifier = "appdb"
  db_name       = "appdb"
  username      = var.rds_username
  password      = var.rds_password

  tags = var.tags
}


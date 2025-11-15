output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC ID"
}

output "public_subnet_id" {
  value       = module.vpc.public_subnet_id
  description = "public subnet ID"
}

output "private_subnet_id" {
  value       = module.vpc.private_subnet_id
  description = "private subnet ID"
}

output "vpc_cidr" {
  value       = module.vpc.vpc_cidr
  description = "VPC CIDR-block"
}

output "availability_zone" {
  value       = module.vpc.availability_zone
  description = "VPC availability zone"
}

output "key_private_pem" {
  value     = module.key.key_private_pem
  sensitive = true
}

output "key_name" {
  value     = module.key.key_name
}


output "ec2s_info" {
  value = {
    for name, mod in module.ec2 :
    name => {
      ec2_id        = mod.instance_id
      ec2_name      = mod.instance_name
      private_ip    = mod.private_ip
      public_ip     = mod.public_ip
      public_dns    = mod.public_dns
      environment   = local.all_ec2s[name].environment
      efs_enable    = local.all_ec2s[name].efs_enable
    }
  }
}

output "fastapi_url" {
  description = "Public URL for FastAPI application"
  value       = try("http://${module.ec2["fastapi"].public_ip}", null)
}


output "vpn_ec2_name" {
  value     = module.vpn.instance_name
  description = "The Name tag of the EC2 instance"
}

output "vpn_ec2_id" {
  value     = module.vpn.instance_id
  description = "The ID of the EC2 instance"
}

output "vpn_public_ip" {
  description = "The public IP of the EC2 instance"
  value       = module.vpn.public_ip
}

output "vpn_private_ip" {
  description = "The private IP of the EC2 instance"
  value       = module.vpn.private_ip
}

output "vpn_domain_name" {
  description = "VPN domain name"
  value       = module.vpn.domain_name
}

output "efs_id" {
  value = module.efs.id
}

output "efs_arn" {
  value = module.efs.arn
}

output "efs_dns_name" {
  value = module.efs.dns_name
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = module.rds.db_endpoint
}

output "rds_address" {
  description = "RDS instance address"
  value       = module.rds.db_address
}

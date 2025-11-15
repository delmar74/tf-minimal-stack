### EC2
locals {
  all_ec2s = {
    for name, ec2 in var.ec2 : name => merge(
      {
        ami_id              = data.aws_ami.ubuntu_24_04.id
        instance_type       = var.ec2_type
        key_name            = module.key.key_name

        vpc_id              = module.vpc.vpc_id
        subnet_id           = lookup(ec2, "use_public_subnet", false) ? module.vpc.public_subnet_id : module.vpc.private_subnet_id
        volume_size         = var.ec2_volume_size
        associate_public_ip = lookup(ec2, "use_public_subnet", false)
        use_fastapi         = lookup(ec2, "use_fastapi", false)

        tags                = var.tags

        efs_dns_name        = module.efs.dns_name
      },
      ec2
    )
  }
}

module "ec2" {
  for_each            = local.all_ec2s
  source              = "../modules/ec2"
  environment         = each.value.environment
  efs_enable          = each.value.efs_enable
  efs_dir             = each.value.efs_dir
  ami_id              = each.value.ami_id
  instance_type       = each.value.instance_type
  key_name            = each.value.key_name
  vpc_id              = each.value.vpc_id
  subnet_id           = each.value.subnet_id
  volume_size         = each.value.volume_size
  associate_public_ip = each.value.associate_public_ip
  use_fastapi         = each.value.use_fastapi
  tags                = each.value.tags
  efs_dns_name        = each.value.efs_dns_name
  
  # Database connection parameters (only for FastAPI instances)
  db_address  = each.value.use_fastapi ? module.rds.db_address : ""
  db_port     = each.value.use_fastapi ? module.rds.db_port : 3306
  db_name     = each.value.use_fastapi ? module.rds.db_name : ""
  db_username = each.value.use_fastapi ? var.rds_username : ""
  db_password = each.value.use_fastapi ? var.rds_password : ""
  
  depends_on = [module.rds]
}

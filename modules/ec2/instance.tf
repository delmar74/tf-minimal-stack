resource "aws_instance" "instance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.sg.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  key_name               = var.key_name
  associate_public_ip_address = var.associate_public_ip

  tags = merge(
    var.tags,
    {
      Name = "${var.tags["Project"]}-ec2-${var.environment}"
      Environment = var.environment
    }
  )

  root_block_device {
    volume_size = var.volume_size
    volume_type = "gp3"
    delete_on_termination = true
  }


  metadata_options {
    http_tokens = "required"
    http_endpoint = "enabled"
    instance_metadata_tags = "enabled"
  }

  user_data = var.use_fastapi ? templatefile("${path.module}/user_data_fastapi.sh.tpl", {
    db_address  = var.db_address
    db_port     = var.db_port
    db_name     = var.db_name
    db_username = var.db_username
    db_password = var.db_password
  }) : templatefile("${path.module}/user_data.sh.tpl", {
    efs_enable            = var.efs_enable
    efs_dns_name          = var.efs_dns_name
    efs_dir               = var.efs_dir
  })
}

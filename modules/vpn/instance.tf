resource "aws_instance" "vpn" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.sg.id]
  key_name               = var.key_name

  depends_on = [aws_security_group.sg]

  tags = merge(
    var.tags,
    {
      Name = "${var.tags["Project"]}-vpn"
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

  user_data = file("${path.module}/user_data.sh")
}


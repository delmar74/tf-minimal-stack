resource "aws_efs_file_system" "efs" {
  creation_token   = "token-efs"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"

  tags = merge(
    var.tags,
    {
      Name = "${var.tags["Project"]}-efs"
    }
  )
}

resource "aws_security_group" "efs_sg" {
  name        = "${var.tags["Project"]}-efs-sg"
  description = "Allow NFS traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Лучше ограничить!
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.tags["Project"]}-efs-sg"
    }
  )
}

resource "aws_efs_mount_target" "efs_mt" {
  file_system_id    = aws_efs_file_system.efs.id
  subnet_id         = var.subnet_id
  security_groups   = [aws_security_group.efs_sg.id]
}


resource "aws_security_group" "sg" {

  name        = "${var.tags["Project"]}-vpn-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = var.vpc_id

  # Inbound rules
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Custom UDP port 14793"
    from_port   = 14793
    to_port     = 14793
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # VPN Admin Panel port (only if different from standard ports)
  dynamic "ingress" {
    for_each = var.admin_port != 22 && var.admin_port != 80 && var.admin_port != 443 ? [1] : []
    content {
      description = "VPN Admin Panel"
      from_port   = var.admin_port
      to_port     = var.admin_port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # HTTPS (only if admin_port is not 443)
  dynamic "ingress" {
    for_each = var.admin_port != 443 ? [1] : []
    content {
      description = "HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # Admin Panel on port 443 (if admin_port is 443)
  dynamic "ingress" {
    for_each = var.admin_port == 443 ? [1] : []
    content {
      description = "VPN Admin Panel (HTTPS)"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # Outbound rule
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.tags["Project"]}-vpn-sg"
    }
  )
}


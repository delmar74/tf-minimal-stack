resource "aws_security_group" "sg" {

  name        = "${var.tags["Project"]}-${var.environment}-ec2-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = var.vpc_id

  # Inbound rules
  ingress {
    description = "All traffic from anywhere"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "All traffic from 109.245.197.254/32"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["109.245.197.254/32"]
  }

  ingress {
    description = "All traffic from 81.200.10.14/32"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["81.200.10.14/32"]
  }

  ingress {
    description = "All traffic from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [data.aws_vpc.this.cidr_block]
  }

  # Outbound rules
  egress {
    description = "All traffic to anywhere"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.tags["Project"]}-${var.environment}-ec2-sg"
    }
  )
}


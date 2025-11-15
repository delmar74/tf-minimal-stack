# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${lower(replace(var.tags["Project"], " ", "-"))}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "${var.tags["Project"]}-db-subnet-group"
    }
  )
}

# Security Group for RDS
resource "aws_security_group" "rds" {
  name        = "${lower(replace(var.tags["Project"], " ", "-"))}-rds-sg"
  description = "Security group for RDS database"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = length(var.allowed_security_group_ids) > 0 ? var.allowed_security_group_ids : []
    content {
      description     = "MySQL/Aurora from EC2"
      from_port       = 3306
      to_port         = 3306
      protocol        = "tcp"
      security_groups = [ingress.value]
    }
  }

  ingress {
    description = "MySQL/Aurora from VPC"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.tags["Project"]}-rds-sg"
    }
  )
}

# RDS Instance
resource "aws_db_instance" "main" {
  identifier             = var.db_identifier
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage
  storage_type           = var.storage_type
  db_name                = var.db_name
  username               = var.username
  password               = var.password
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  
  skip_final_snapshot    = true
  publicly_accessible    = false
  multi_az               = false

  tags = merge(
    var.tags,
    {
      Name = "${var.tags["Project"]}-${var.db_identifier}"
    }
  )
}


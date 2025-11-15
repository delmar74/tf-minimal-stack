variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR"
}

variable "vpc_public_subnet_cidr" {
  type        = string
  description = "Public subnet CIDR"
}

variable "vpc_private_subnet_cidr" {
  type        = string
  description = "Private subnet CIDR"
}


variable "ec2_type" {
  type        = string
  description = "Type for EC2 instance"
}

variable "ec2_volume_size" {
  type        = number
  description = "Volume size for EC2 instance"
}

variable "ec2" {
  default = {}
  description = "Only unique parameters for EC2 instances"
  type = map(object({
    environment      = string
    efs_enable       = bool
    efs_dir          = string
    use_public_subnet = optional(bool, false)
    use_fastapi      = optional(bool, false)
  }))
}


variable "vpn_ec2_type" {
  type        = string
  description = "Type for EC2 instance"
}

variable "vpn_ec2_volume_size" {
  type        = number
  description = "Volume size for EC2 instance"
}

variable "vpn_admin_port" {
  type        = number
  description = "Port for VPN admin panel access from public internet"
  default     = 443
}

variable "rds_username" {
  type        = string
  description = "RDS master username"
  default     = "admin"
}

variable "rds_password" {
  type        = string
  description = "RDS master password"
  sensitive   = true
}

variable "tags" {
  type        = map(string)
  description = "Common tags to apply to resources"
}

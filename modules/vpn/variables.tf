variable "ami_id" {
  type        = string
  description = "AMI ID for EC2 instance"
}

variable "key_name" {
  type        = string
  description = "Key pair"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}

variable "subnet_id" {
  type        = string
  description = "existing subnet id"
}

variable "tags" {
  type        = map(string)
  description = "Common tags to apply to resources"
}

variable "volume_size" {
  type        = number
  description = "Root volume size in GiB"
  default     = 50
}

variable "assign_static_private_ip" {
  type        = bool
  description = "Whether to assign a static private IP"
  default     = false
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "admin_port" {
  type        = number
  description = "Port for VPN admin panel access from public internet"
  default     = 443
}

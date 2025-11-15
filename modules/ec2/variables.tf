variable "ami_id" {
  type        = string
  description = "AMI ID for EC2 instance"
}

variable "key_name" {
  type        = string
  description = "Key pair"
}

variable "environment" {
  type        = string
  description = "Environment type (dev, test, prod)"
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

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "efs_enable" {
  type    = bool
  default = false
}

variable "efs_dns_name" {
  type    = string
  default = ""
}

variable "efs_dir" {
  type    = string
  default = ""
}

variable "associate_public_ip" {
  type        = bool
  description = "Whether to associate a public IP address with the instance"
  default     = false
}

variable "use_fastapi" {
  type        = bool
  description = "Whether to use FastAPI user_data template"
  default     = false
}

variable "db_address" {
  type        = string
  description = "Database address"
  default     = ""
}

variable "db_port" {
  type        = number
  description = "Database port"
  default     = 3306
}

variable "db_name" {
  type        = string
  description = "Database name"
  default     = ""
}

variable "db_username" {
  type        = string
  description = "Database username"
  default     = ""
}

variable "db_password" {
  type        = string
  description = "Database password"
  default     = ""
  sensitive   = true
}


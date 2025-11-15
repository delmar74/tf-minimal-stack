variable "vpc_cidr" {}
variable "vpc_name" {}

variable "public_subnet_cidr" {}
variable "public_subnet_name" {}

variable "private_subnet_cidr" {}
variable "private_subnet_name" {}

variable "availability_zone" {}

variable "igw_name" {}
variable "nat_name" {}

variable "public_rt_name" {}
variable "private_rt_name" {}

variable "tags" {
  type    = map(string)
  default = {}
}


variable "vpc_id" {}
variable "subnet_id" {}

variable "tags" {
  type        = map(string)
  description = "Common tags to apply to resources"
}

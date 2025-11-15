output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}

output "availability_zone" {
  value = aws_subnet.public.availability_zone
}

output "vpc_cidr" {
  value = aws_vpc.this.cidr_block
}

output "nat_gateway_id" {
  value = aws_nat_gateway.this.id
}



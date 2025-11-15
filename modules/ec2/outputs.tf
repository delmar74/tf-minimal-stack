output "instance_name" {
  description = "The Name tag of the EC2 instance"
  value       = lookup(aws_instance.instance.tags, "Name", "N/A")
}

output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.instance.id
}

output "private_ip" {
  description = "The private IP of the EC2 instance"
  value       = aws_instance.instance.private_ip
}

output "public_ip" {
  description = "The public IP of the EC2 instance"
  value       = aws_instance.instance.public_ip
}

output "public_dns" {
  description = "The public DNS name of the EC2 instance"
  value       = aws_instance.instance.public_dns
}

output "security_group_id" {
  description = "The security group ID of the EC2 instance"
  value       = aws_security_group.sg.id
}


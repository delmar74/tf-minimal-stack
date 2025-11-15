output "instance_name" {
  description = "The Name tag of the EC2 instance"
  value       = lookup(aws_instance.vpn.tags, "Name", "N/A")
}

output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.vpn.id
}

output "public_ip" {
  description = "Public IP"
  value       = aws_instance.vpn.public_ip
}

output "private_ip" {
  description = "Private IP"
  value       = aws_instance.vpn.private_ip
}

output "domain_name" {
  description = "Auto-generated DNS name from EC2"
  value       = aws_instance.vpn.public_dns
}



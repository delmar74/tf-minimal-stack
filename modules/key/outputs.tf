output "key_private_pem" {
  value = tls_private_key.key.private_key_pem
  sensitive = true 
}

output "key_name" {
  value = aws_key_pair.generated.key_name
}

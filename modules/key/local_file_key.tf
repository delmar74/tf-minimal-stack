resource "local_file" "private_key" {
  content  = tls_private_key.key.private_key_pem
  filename = "${path.module}/../../${var.tags["Project"]}-key.pem"
  file_permission = "0700"
}

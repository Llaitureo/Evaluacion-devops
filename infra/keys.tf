resource "aws_key_pair" "ssh_access" {
  key_name   = "llave-ssh"
  public_key = "ssh-rsa mi-llave-publica-aqui" // Reemplaza con tu clave pública real
}
resource "aws_key_pair" "ssh_access" {
  key_name   = "mi_llave-ssh"
  public_key = "llave_pública" // Reemplaza con tu clave pública real
}
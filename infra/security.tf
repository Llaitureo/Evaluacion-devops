resource "aws_security_group" "web_sg" { //Grupo de seguridad para la capa web ------------------------------------- 1
  name        = "web_sg"
  description = "Allow HTTP traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { //SSH para administración remota
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["123.456.789.123/32"] //Permite acceso solo desde esta IP, CAMBIAR POR TU IP REAL
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Permite todo el tráfico de salida
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "backend_sg" { //Grupo de seguridad para la capa de backend ------------------------------------- 2
  name        = "backend_sg"
  description = "Allow traffic from web_sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id] // Permite tráfico solo desde el grupo de seguridad web_sg
  }

  ingress { //SSH para administración remota
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id] // Permite acceso solo desde el grupo de seguridad web_sg
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "data_sg" { //Grupo de seguridad para la capa de datos ------------------------------------- 3
  name        = "data_sg"
  description = "Allow traffic from backend_sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.backend_sg.id] // Permite tráfico solo desde el grupo de seguridad backend_sg
  }

  ingress { //SSH para administración remota
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id] // Permite acceso solo desde el grupo de seguridad web_sg
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
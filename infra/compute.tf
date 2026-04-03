// Infraestructura para el proyecto Innovatech ------------------------------- 1
resource "aws_launch_template" "front_template" {
  name_prefix   = "front-template-"
  image_id      = "ami-0c02fb55956c7d316" // Amazon Linux 2 AMI
  instance_type = "t2.micro"
  key_name      = aws_key_pair.ssh_access.key_name

  iam_instance_profile {
    name = data.aws_iam_instance_profile.lab_profile.name
  }

  # Configuración de red para el Front
  network_interfaces {
    subnet_id                   = aws_subnet.public.id
    associate_public_ip_address = true # ESTO LO HACE PÚBLICO
    security_groups             = [aws_security_group.web_sg.id]
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash

    until curl -s --head http://www.google.com | head -n 1 | grep "200 OK" > /dev/null; do //Espera a que la instancia tenga conexión a internet antes de continuar
      echo "Esperando conexión a internet..."
      sleep 5
    done
    # Actualizar paquetes
    yum update -y
    
    amazon-linux-extras install docker -y
    systemctl enable docker
    systemctl start docker
    
    usermod -aG docker ec2-user
    yum install git -y
    
    docker run -d --restart always -p 80:80 --name web-front nginx
  EOF
  )
}

resource "aws_launch_template" "back_template" {
  name_prefix   = "back-template-"
  image_id      = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.ssh_access.key_name

  iam_instance_profile {
    name = data.aws_iam_instance_profile.lab_profile.name
  }

  # Configuración de red para el Back
  network_interfaces {
    subnet_id                   = aws_subnet.private.id
    associate_public_ip_address = false # ESTO LO MANTIENE PRIVADO
    security_groups             = [aws_security_group.backend_sg.id]
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash

    until curl -s --head http://www.google.com | head -n 1 | grep "200 OK" > /dev/null; do //Espera a que la instancia tenga conexión a internet antes de continuar, crucial para la instalación de paquetes.
      echo "Esperando conexión a internet..."
      sleep 5
    done
    yum update -y
    amazon-linux-extras install docker -y
    yum install git nmap-ncat -y  # Herramientas para clonar el código y validar la conectividad de red
    
    systemctl enable docker
    systemctl start docker
    usermod -aG docker ec2-user

    yum install git -y
  EOF
  )
}

resource "aws_launch_template" "data_template" {
  name_prefix   = "data-db-"
  image_id      = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.ssh_access.key_name

  network_interfaces {
    subnet_id                   = aws_subnet.private.id
    associate_public_ip_address = false
    security_groups             = [aws_security_group.data_sg.id]
  }

  iam_instance_profile {
    name = data.aws_iam_instance_profile.lab_profile.name
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash

    until curl -s --head http://www.google.com | head -n 1 | grep "200 OK" > /dev/null; do
      echo "Esperando conexión a internet..."
      sleep 5
    done
    yum update -y
    
    yum install -y mariadb-server
    
    # Iniciar y habilitar el servicio (MysQL/MariaDB)
    systemctl start mariadb
    systemctl enable mariadb
    
    sleep 2 # Esperar a que el servicio esté completamente iniciado
    mysql -e "CREATE DATABASE innovatechdb;"
  EOF
  )
}

// Instancias EC2 para cada capa de la aplicación ------------------------------------- 2
resource "aws_instance" "front_server" {
  launch_template {
    id      = aws_launch_template.front_template.id
    version = "$Latest"
  }

  tags = {
    Name = "Front-Server-Innovatech"
  }
}

resource "aws_instance" "back_server" {
  launch_template {
    id      = aws_launch_template.back_template.id
    version = "$Latest"
  }

  tags = {
    Name = "Back-Server-Innovatech"
  }
  depends_on = [aws_nat_gateway.nat_gw]
}

resource "aws_instance" "data_server" {
  launch_template {
    id      = aws_launch_template.data_template.id
    version = "$Latest"
  }

  tags = {
    Name = "Data-Server-Innovatech"
  }
  depends_on = [aws_nat_gateway.nat_gw]
}

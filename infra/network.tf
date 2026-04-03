resource "aws_vpc" "main" { //Creación de la VPC ------------------------------------- 1
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "main_vpc"
  }
}

resource "aws_internet_gateway" "igw" { //Creación del Internet Gateway ------------------------------------- 2
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main_igw"
  }

}

resource "aws_eip" "nat" { //Creación de la Elastic IP para el NAT Gateway ------------------------------------- 3
  domain = "vpc"

  tags = {
    Name = "nat_eip"
  }
}

resource "aws_nat_gateway" "nat_gw" { //Creación del NAT Gateway ------------------------------------- 4
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
  depends_on    = [aws_internet_gateway.igw]
  tags = {
    Name = "main_nat_gateway"
  }

}

//Subnets
resource "aws_subnet" "public" { //Creación de la Subnet Pública
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet"
  }
}

resource "aws_subnet" "private" { //Creación de la Subnet Privada
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "private_subnet"
  }

}

//Route Table para la Subnets
resource "aws_route_table" "public_rt" { //Creación de la Route Table Pública ------------------------------------- 5
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id //Usa internet Gateway
  }
  tags = {
    Name = "public_route_table"
  }
}

resource "aws_route_table" "private_rt" { //Creación de la Route Table Privada 
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id //Usa NAT Gateway
  }
  tags = {
    Name = "private_route_table"
  }
}

//Asociación de tablas
resource "aws_route_table_association" "public_assoc" { //Asociación de la Route Table Pública a la Subnet Pública ------------------------------------- 6
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_association" { //Asociación de la Route Table Privada a la Subnet Privada
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private_rt.id
}


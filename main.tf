resource "aws_vpc" "my-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "myvpc"
  }
}

resource "aws_subnet" "pub-sn" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "${var.region}a"
  tags = {
    Name = "pub-sn"
  }
}

resource "aws_subnet" "priv-sn" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "${var.region}b"
  tags = {
    Name = "priv-sn"
  }
}

resource "aws_internet_gateway" "tigw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "igw"
  }
}

resource "aws_route_table" "pub-rt" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tigw.id
  }

  tags = {
    Name = "pub-rt"
  }
}

resource "aws_eip" "teip" {
  domain   = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.teip.id
  subnet_id     = aws_subnet.pub-sn.id

  tags = {
    Name = "NAT"
  }
}

resource "aws_route_table" "pri-rt" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "priv-rt"
  }
}

resource "aws_route_table_association" "psna" {
  subnet_id      = aws_subnet.pub-sn.id
  route_table_id = aws_route_table.pub-rt.id
}

resource "aws_route_table_association" "privsna" {
  subnet_id      = aws_subnet.priv-sn.id
  route_table_id = aws_route_table.pri-rt.id
}

resource "aws_security_group" "pub-sg" {
  name        = "allow_tls-1"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.my-vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "pub-sg"
  }
}

resource "aws_security_group" "pri-sg" {
  name        = "allow_tls-2"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.my-vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 0
    to_port          = 65535
    protocol         = "tcp"
    cidr_blocks      = ["10.0.1.0/24"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "priv-sg"
  }
}

resource "aws_instance" "pubinstance" {
  ami                                             = var.ami
  instance_type                                   = "t2.micro"
  availability_zone                               = "${var.region}a"
  associate_public_ip_address                     = "true"
  vpc_security_group_ids                          = [aws_security_group.pub-sg.id]
  subnet_id                                       = aws_subnet.pub-sn.id
  key_name                                        = "lin"

    tags = {
    Name = "pub-server"
  }
}

resource "aws_instance" "privinstance" {
  ami                                             = var.ami
  instance_type                                   = "t2.micro"
  availability_zone                               = "${var.region}b"
  associate_public_ip_address                     = "true"
  vpc_security_group_ids                          = [aws_security_group.pri-sg.id]
  subnet_id                                       = aws_subnet.priv-sn.id
  key_name                                        = "lin"

    tags = {
    Name = "pri-server"
  }
}

# resource "github_repository" "example" {
#   name        = "example"
#   description = "My awesome codebase"

#   visibility = "public"

# }

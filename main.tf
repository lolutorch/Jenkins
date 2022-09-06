resource "aws_vpc" "Ample-VPC" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default" 

  tags = {
    Name = "Ample-VPC"
  }
}

resource "aws_subnet" "Ample_subnetA" {
  vpc_id     = aws_vpc.Ample-VPC.id
  cidr_block = "10.0.1.0/24"
   availability_zone = "us-east-1a"
   map_public_ip_on_launch = true

  tags = {
    Name = "Ample_subnetA"
  }
}

resource "aws_subnet" "Ample_subnetB" {
  vpc_id     = aws_vpc.Ample-VPC.id
  cidr_block = "10.0.2.0/24"
   availability_zone = "us-east-1b"
   map_public_ip_on_launch = true 

  tags = {
    Name = "Ample_subnetB"
  }
}

resource "aws_internet_gateway" "Ample-igw" {
  vpc_id = aws_vpc.Ample-VPC.id

  tags = {
    Name = "Ample-igw"
  }
}

resource "aws_route_table" "Ample-RT" {
  vpc_id = aws_vpc.Ample-VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Ample-igw.id
  }

  tags = {
    Name = "Ample-RT"
  }
}

resource "aws_route_table_association" "rta-1" {
  subnet_id      = aws_subnet.Ample_subnetA.id
  route_table_id = aws_route_table.Ample-RT.id
}

resource "aws_route_table_association" "rta-2" {
  subnet_id      = aws_subnet.Ample_subnetB.id
  route_table_id = aws_route_table.Ample-RT.id
}


resource "aws_security_group" "Ample-SG1" {
  name        = "web security group"
  description = "Ample-SG1 allow HTTP traffic"
  vpc_id      = aws_vpc.Ample-VPC.id

  ingress {
    description      = "HTTP traffic"
    from_port        = 8080
    to_port          = 8080
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
    Name = "Ample-SG1"
  }
}

resource "aws_instance" "webserver1" {
  ami = "ami-047bb4163c506cd98"
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"
  vpc_security_group_ids = [aws_security_group.Ample-SG1.id]
  subnet_id = "aws_subnet.Ample_subnetA.id"
  user_data = file(install_apache.sh)

 tags = {
    Name = "webserver1"
  }

}

resource "aws_instance" "webserver2" {
  ami = "ami-047bb4163c506cd98"
  instance_type = "t2.micro"
  availability_zone = "us-east-1b"
  vpc_security_group_ids = [aws_security_group.Ample-SG1.id]
  subnet_id = "aws_subnet.Ample_subnetB.id"
  user_data = file(install_apache.sh)

 tags = {
    Name = "webserver2"
  }

}
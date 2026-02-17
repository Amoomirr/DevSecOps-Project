resource "aws_vpc" "netflix_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Netflix_VPC"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.netflix_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.netflix_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.netflix_vpc.id
  tags = {
    Name = "Monitoring-IGW"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.netflix_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "Netflix-Public-RT"
  } 
}

resource "aws_route_table_association" "public_rt_association" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_route_table_association" "public_rt_association_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "netflix_sg" {
  name = "Netflix"
  description = "Allow ICMP, SSH , HTTP Traffic"
  vpc_id = aws_vpc.netflix_vpc.id

  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
    }
  ingress {
    description = "Sonarqube"
    from_port = 9000
    to_port = 9000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
    }
  ingress {
    description = "app-port"
    from_port = 8081
    to_port = 8081
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
    }

  ingress {
    description = "Jenkins"
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Netflix-SG"
  }
}
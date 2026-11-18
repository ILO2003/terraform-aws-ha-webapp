terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

}
provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "webapp-vpc" {
  cidr_block = var.cidr_block
  tags = {
    Name = "terraform-created-vpc"
  }
}

resource "aws_subnet" "public-subnet-az1" {
  vpc_id            = aws_vpc.webapp-vpc.id
  cidr_block        = "10.20.1.0/24"
  availability_zone = var.az_1

  tags = {
    Name = "Public-AZ1"
  }
}
resource "aws_subnet" "public-subnet-az2" {
  vpc_id            = aws_vpc.webapp-vpc.id
  cidr_block        = "10.20.2.0/24"
  availability_zone = var.az_2
  tags = {
    Name = "Public-AZ2"
  }
}
resource "aws_subnet" "private-app-subnet-az1" {
  vpc_id            = aws_vpc.webapp-vpc.id
  cidr_block        = "10.20.11.0/24"
  availability_zone = var.az_1

  tags = {
    Name = "Private-app-AZ1"
  }
}
resource "aws_subnet" "private-app-subnet-az2" {
  vpc_id            = aws_vpc.webapp-vpc.id
  cidr_block        = "10.20.12.0/24"
  availability_zone = var.az_2

  tags = {
    Name = "Private-app-AZ2"
  }
}
resource "aws_subnet" "private-DB-subnet-az1" {
  vpc_id            = aws_vpc.webapp-vpc.id
  cidr_block        = "10.20.21.0/24"
  availability_zone = var.az_1

  tags = {
    Name = "Private-DB-AZ1"
  }
}
resource "aws_subnet" "private-DB-subnet-az2" {
  vpc_id            = aws_vpc.webapp-vpc.id
  cidr_block        = "10.20.22.0/24"
  availability_zone = var.az_2

  tags = {
    Name = "Private-DB-AZ2"
  }
}


resource "aws_internet_gateway" "terraform-ha-webapp-igw" {
  vpc_id = aws_vpc.webapp-vpc.id

  tags = {
    Name = "webapp-igw"
  }
}

resource "aws_route_table" "terraform-ha-rt-pub" {
  vpc_id = aws_vpc.webapp-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform-ha-webapp-igw.id
  }
  tags = {
    Name = "terraform-rt-pub"
  }
}
resource "aws_route_table" "terraform-ha-rt-app-private" {
  vpc_id = aws_vpc.webapp-vpc.id
  tags = {
    Name = "terraform-rt-app-private"
  }
}
resource "aws_route_table" "terraform-ha-rt-db-private" {
  vpc_id = aws_vpc.webapp-vpc.id
  tags = {
    Name = "terraform-rt-db-private"
  }
}

resource "aws_route_table_association" "public-app-AZ1-association" {
  subnet_id      = aws_subnet.public-subnet-az1.id
  route_table_id = aws_route_table.terraform-ha-rt-pub.id
}
resource "aws_route_table_association" "public-app-AZ2-association" {
  subnet_id      = aws_subnet.public-subnet-az2.id
  route_table_id = aws_route_table.terraform-ha-rt-pub.id
}
resource "aws_route_table_association" "private-app-AZ1-association" {
  subnet_id      = aws_subnet.private-app-subnet-az1.id
  route_table_id = aws_route_table.terraform-ha-rt-app-private.id
}
resource "aws_route_table_association" "private-app-AZ2-association" {
  subnet_id      = aws_subnet.private-app-subnet-az2.id
  route_table_id = aws_route_table.terraform-ha-rt-app-private.id
}
resource "aws_route_table_association" "private-db-AZ1-association" {
  subnet_id      = aws_subnet.private-DB-subnet-az1.id
  route_table_id = aws_route_table.terraform-ha-rt-db-private.id
}
resource "aws_route_table_association" "private-db-AZ2-association" {
  subnet_id      = aws_subnet.private-DB-subnet-az2.id
  route_table_id = aws_route_table.terraform-ha-rt-db-private.id
}
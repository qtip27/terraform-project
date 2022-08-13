#Resources
#VPC
resource "aws_vpc" "mtc_vpc" {
  cidr_block           = ""
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "Dev"
  }
}

#SUBNET'S
#Public Subnet #1
resource "aws_subnet" "mtc_public_subnet" {
  vpc_id                  = aws_vpc.mtc_vpc.id #Referencing the VPC above with the ID of that VPC
  cidr_block              = ""
  map_public_ip_on_launch = true
  availability_zone       = "us-east-2a"

  tags = {
    Name = "dev-public-1"
  }
}


#Private Subnet #1
resource "aws_subnet" "mtc_private_subnet" {
  vpc_id                  = aws_vpc.mtc_vpc.id #Referencing the VPC above with the ID of that VPC
  cidr_block              = ""
  map_public_ip_on_launch = false
  availability_zone       = "us-east-2a"

  tags = {
    Name = "dev-private"
  }
}

#Public Subnet #2
resource "aws_subnet" "mtc_public_subnet_2" {
  vpc_id                  = aws_vpc.mtc_vpc.id #Referencing the VPC above with the ID of that VPC
  cidr_block              = ""
  map_public_ip_on_launch = true
  availability_zone       = "us-east-2a"

  tags = {
    Name = "dev-public-2"
  }
}



#Private Subnet #2
resource "aws_subnet" "mtc_private_subnet_2" {
  vpc_id                  = aws_vpc.mtc_vpc.id #Referencing the VPC above with the ID of that VPC
  cidr_block              = ""
  map_public_ip_on_launch = false
  availability_zone       = "us-east-2a"

  tags = {
    Name = "dev-private-2"
  }
}


#INTERNET GATEWAY
resource "aws_internet_gateway" "mtc_internet_gateway" {
  vpc_id = aws_vpc.mtc_vpc.id

  tags = {
    Name = "dev-igw"
  }
}

#ROUTING TABLE
resource "aws_route_table" "mtc_public_rt" {
  vpc_id = aws_vpc.mtc_vpc.id

  tags = {
    Name = "dev_public_rt"
  }
}

#DEFAULT ROUTE
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.mtc_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.mtc_internet_gateway.id
}

#ROUTING TABLE ASSOC.
resource "aws_route_table_association" "mtc_public_assoc" {
  subnet_id      = aws_subnet.mtc_public_subnet.id
  route_table_id = aws_route_table.mtc_public_rt.id
}

resource "aws_route_table_association" "mtc_public_assoc_2" {
  subnet_id      = aws_subnet.mtc_public_subnet_2.id
  route_table_id = aws_route_table.mtc_public_rt.id
}

#Load Balancer
resource "aws_lb" "mtc_load_balancer" {
  name               = "mtc-lb-tf"
  internal           = false
  load_balancer_type = "network"
  subnets            = [aws_subnet.mtc_public_subnet.id]

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

# Fetch Availability Zones
data "aws_availability_zones" "available" {}

# Create VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "main-vpc" }
}

# Create Public Subnets
resource "aws_subnet" "public" {
  count                   = var.number_of_azs
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 4, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = { Name = "public-subnet-${count.index + 1}" }
}

# Create Private Subnets
resource "aws_subnet" "private" {
  count             = var.number_of_azs
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 4, count.index + var.number_of_azs) # Avoid overlap with public subnets
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = { Name = "private-subnet-${count.index + 1}" }
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "main-igw" }
}

# Create Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "public-route-table" }
}

# Create Public Route to IGW
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Associate Public Subnets with Route Table
resource "aws_route_table_association" "public" {
  count          = var.number_of_azs
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}


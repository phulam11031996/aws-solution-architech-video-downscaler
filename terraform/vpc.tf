
data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" { cidr_block = var.vpc_cidr enable_dns_support = true enable_dns_hostnames = true tags = { Name = "main-vpc" } }

resource "aws_subnet" "public" {
count = var.number_of_azs
vpc_id = aws_vpc.main.id
cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 4, count.index)
availability_zone = data.aws_availability_zones.available.names[count.index]
map_public_ip_on_launch = true
tags = { Name = "public-subnet-${count.index + 1}" } }

resource "aws_subnet" "private" { count = var.number_of_azs vpc_id = aws_vpc.main.id cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 4, count.index + var.number_of_azs) availability_zone = data.aws_availability_zones.available.names[count.index] tags = { Name = "private-subnet-${count.index + 1}" } }

resource "aws_subnet" "private_video" { count = var.number_of_azs vpc_id = aws_vpc.main.id cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 4, 2 * var.number_of_azs + count.index) availability_zone = data.aws_availability_zones.available.names[count.index] tags = { Name = "private-video-subnet-${count.index + 1}" } }

resource "aws_internet_gateway" "igw" { vpc_id = aws_vpc.main.id tags = { Name = "main-igw" } }

resource "aws_route_table" "public" { vpc_id = aws_vpc.main.id tags = { Name = "public-route-table" } }

resource "aws_route_table_association" "public" {
count = var.number_of_azs subnet_id = aws_subnet.public[count.index].id route_table_id = aws_route_table.public.id }

resource "aws_route" "public_internet_access" {
route_table_id = aws_route_table.public.id destination_cidr_block = "0.0.0.0/0" gateway_id = aws_internet_gateway.igw.id }

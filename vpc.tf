# AZs disponibles en la región (tomaremos 3)
data "aws_availability_zones" "this" {
  state = "available"
}

# VPC (barrio)
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "${var.project_name}-vpc" }
}

# Internet Gateway (salida a Internet)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.project_name}-igw" }
}

# Subredes públicas (3), una por AZ, /24 usando cidrsubnet()
resource "aws_subnet" "public" {
  count                   = 3
  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = data.aws_availability_zones.this.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}-public-${count.index + 1}"
    Tier = "public"
  }
}

# Route table pública + ruta a Internet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.project_name}-public-rt" }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Subredes privadas (2) para RDS
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 100) # 10.10.100.0/24, 10.10.101.0/24
  availability_zone = data.aws_availability_zones.this.names[count.index]
  tags = {
    Name = "${var.project_name}-private-${count.index + 1}"
    Tier = "private"
  }
}

# Route table privada (sin salida directa a Internet)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.project_name}-private-rt" }
}

resource "aws_route_table_association" "private_assoc" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

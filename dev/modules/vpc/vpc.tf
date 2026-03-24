resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.env}-${var.vpc_name}"
    env  = var.env
  }
}


#subnet

resource "aws_subnet" "public_subnet" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.public_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "Public-Subnet--${var.env}-${count.index + 1}"
    env  = var.env
  }
}

resource "aws_subnet" "private_subnet" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "Private-Subnet--${var.env}-${count.index + 1}"
    env  = var.env
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.env}-${var.igw_name}"
    env  = var.env
  }
  depends_on = [aws_vpc.main]
}

resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? 1 : 0
  domain = "vpc"
  tags = {
    Name = "${var.env}-${var.vpc_name}-nat-eip"
    env  = var.env
  }
}

resource "aws_nat_gateway" "ngw" {
  count         = var.enable_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = {
    Name = "${var.env}-${var.ngw_name}"
    env  = var.env
  }

  depends_on = [aws_internet_gateway.igw, aws_eip.nat]
}


resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.env}-${var.vpc_name}-public-rtb"
    env  = var.env
  }
}

resource "aws_route_table" "private_rtb" {
  vpc_id = aws_vpc.main.id
  count  = var.enable_nat_gateway ? 1 : 0

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw[0].id
  }
  tags = {
    Name = "${var.env}-${var.vpc_name}-private-rtb-test"
    env  = var.env
  }
}

resource "aws_route_table_association" "public_rtb_association" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rtb.id
}

resource "aws_route_table_association" "private_rtb_association" {
  count          = var.enable_nat_gateway ? length(var.private_subnet_cidrs) : 0
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_rtb[0].id
}
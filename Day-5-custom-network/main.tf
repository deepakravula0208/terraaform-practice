locals {
  public_map  = { for idx, cidr in var.public_subnets  : tostring(idx) => cidr }
  private_map = { for idx, cidr in var.private_subnets : tostring(idx) => cidr }
}

# VPC
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge({ Name = "custom-vpc" }, var.tags)
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags   = merge({ Name = "custom-igw" }, var.tags)
}

# Public subnets
resource "aws_subnet" "public" {
  for_each = local.public_map

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value
  availability_zone       = element(var.azs, tonumber(each.key))
  map_public_ip_on_launch = true

  tags = merge({ Name = "public-${each.key}" }, var.tags)
}

# Private subnets
resource "aws_subnet" "private" {
  for_each = local.private_map

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = element(var.azs, tonumber(each.key))

  tags = merge({ Name = "private-${each.key}" }, var.tags)
}
# EIPs for NAT (if NAT enabled)
resource "aws_eip" "nat" {
  count  = var.enable_nat ? length(var.azs) : 0
  domain = "vpc"

  tags = merge({
    Name = "nat-eip-${count.index}"
  }, var.tags)
}


# NAT Gateways (one per AZ) placed in corresponding public subnet
resource "aws_nat_gateway" "nat" {
  count         = var.enable_nat ? length(var.azs) : 0
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = element(values(aws_subnet.public)[*].id, count.index)
  tags          = merge({ Name = "nat-${count.index}" }, var.tags)

  depends_on = [aws_internet_gateway.igw]
}

# Public route table + route to IGW
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags   = merge({ Name = "public-rt" }, var.tags)
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc" {
  for_each = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Private route tables (one per private subnet) -> route to NAT if enabled
resource "aws_route_table" "private" {
  for_each = aws_subnet.private
  vpc_id   = aws_vpc.this.id
  tags     = merge({ Name = "private-rt-${each.key}" }, var.tags)
}

resource "aws_route" "private_egress" {
  count = var.enable_nat ? length(aws_route_table.private) : 0

  route_table_id         = element(values(aws_route_table.private), count.index).id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[count.index].id
}

resource "aws_route_table_association" "private_assoc" {
  for_each = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}

# Example security group for bastion (SSH) - tighten in production
resource "aws_security_group" "bastion" {
  name        = "bastion-sg"
  description = "Allow SSH to bastion"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({ Name = "bastion-sg" }, var.tags)
}

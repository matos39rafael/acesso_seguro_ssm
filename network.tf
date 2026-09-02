resource "aws_vpc" "principal" {
  cidr_block           = var.aws_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}_vpc_principal"
  }
}

#internet gateway
resource "aws_internet_gateway" "net_gateway" {
  vpc_id = aws_vpc.principal.id

  tags = {
    Name = "${var.project_name}_internet_gateway"
  }
}

#subnets
resource "aws_subnet" "public" {
  for_each = var.subnets

  vpc_id                  = aws_vpc.principal.id
  cidr_block              = each.value.public_cidr
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}_vpc_principal_public_${each.key}"
  }
}

resource "aws_subnet" "private_app" {
  for_each = var.subnets

  vpc_id            = aws_vpc.principal.id
  cidr_block        = each.value.private_app_cidr
  availability_zone = each.value.availability_zone

  tags = {
    Name = "${var.project_name}_vpc_principal_private_app_${each.key}"
  }
}

resource "aws_subnet" "private_db" {
  for_each = var.subnets

  vpc_id            = aws_vpc.principal.id
  cidr_block        = each.value.private_db_cidr
  availability_zone = each.value.availability_zone

  tags = {
    Name = "${var.project_name}_vpc_principal_private_db_${each.key}"
  }
}

#routing table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.principal.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.net_gateway.id
  }
  tags = {
    Name = "${var.project_name}_vpc_principal_public_route"
  }
}

resource "aws_route_table" "private_app" {
  for_each = var.subnets
  vpc_id   = aws_vpc.principal.id
  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = aws_instance.nat_instance[each.key].primary_network_interface_id
  }
  tags = {
    Name = "${var.project_name}_private_app_route_${each.key}"
  }

  depends_on = [aws_internet_gateway.net_gateway]

}

resource "aws_route_table" "private_db" {
  for_each = var.subnets
  vpc_id   = aws_vpc.principal.id
  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = aws_instance.nat_instance[each.key].primary_network_interface_id
  }
  tags = {
    Name = "${var.project_name}_private_db_route_${each.key}"
  }

  depends_on = [aws_internet_gateway.net_gateway]

}

#routing table association
resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_app" {
  for_each       = var.subnets
  subnet_id      = aws_subnet.private_app[each.key].id
  route_table_id = aws_route_table.private_app[each.key].id
}

resource "aws_route_table_association" "private_db" {
  for_each       = var.subnets
  subnet_id      = aws_subnet.private_db[each.key].id
  route_table_id = aws_route_table.private_db[each.key].id
}

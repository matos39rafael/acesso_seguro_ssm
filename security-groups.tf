resource "aws_security_group" "nat" {
  for_each = var.subnets
  name     = "${var.project_name}_nat_sg_${each.key}"
  vpc_id   = aws_vpc.principal.id

  ingress {
    description = "Allow inbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = [aws_vpc.principal.cidr_block]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.project_name}_nat_sg_${each.key}"
  }
}


resource "aws_security_group" "private_app" {
  name   = "${var.project_name}_private_app_sg"
  vpc_id = aws_vpc.principal.id


  egress {
    description = "traffic through NAT"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.project_name}_private_app_sg"
  }
}


resource "aws_security_group" "private_db" {
  name   = "${var.project_name}_private_db_sg"
  vpc_id = aws_vpc.principal.id

  ingress {
    description     = "Allow traffic from App-SG"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.private_app.id]
  }

  egress {
    description = "Allow outbound HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.project_name}_private_db_sg"
  }
}

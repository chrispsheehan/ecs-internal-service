resource "aws_ecs_cluster" "this" {
  name = "${var.project_name}-cluster"
}

resource "aws_security_group" "vpc_endpoint" {
  name        = "${var.project_name}-vpc-endpoint-sg"
  description = "Security group for VPC endpoints"
  vpc_id      = data.aws_vpc.this.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.this.cidr_block]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.this.cidr_block]
  }
}

resource "aws_vpc_endpoint" "interface_endpoints" {
  for_each            = local.interface_endpoints
  vpc_id              = data.aws_vpc.this.id
  service_name        = "com.amazonaws.${var.aws_region}.${each.value}"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.vpc_endpoint.id]
  subnet_ids          = data.aws_subnets.private.ids
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "gateway_s3" {
  vpc_id            = data.aws_vpc.this.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = data.aws_route_tables.subnet_route_tables.ids
}

resource "aws_eip" "nat_eip" {
  count  = length(data.aws_subnets.public.ids)
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  count         = length(data.aws_subnets.public.ids)
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = data.aws_subnets.public.ids[count.index]
}

resource "aws_route" "private_nat_route" {
  count                  = length(data.aws_route_tables.subnet_route_tables.ids)
  route_table_id         = data.aws_route_tables.subnet_route_tables.ids[count.index]
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[count.index].id
}

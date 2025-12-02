resource "aws_vpc_endpoint" "interface_endpoints" {
  for_each            = local.interface_endpoints
  vpc_id              = data.aws_vpc.this.id
  service_name        = "com.amazonaws.${var.aws_region}.${each.value}"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [data.terraform_remote_state.security.outputs.vpc_endpoint_sg]
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

resource "aws_apigatewayv2_vpc_link" "vpc_link" {
  name               = "${var.project_name}-vpc-link"
  subnet_ids         = data.aws_subnets.private.ids
  security_group_ids = [data.terraform_remote_state.security.outputs.vpc_link_sg]
}

resource "aws_apigatewayv2_api" "http_api" {
  name          = "${var.project_name}-http-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lb" "internal" {
  name               = "${var.project_name}-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [data.terraform_remote_state.security.outputs.lb_sg]

  subnets = data.aws_subnets.private.ids
}

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

resource "aws_apigatewayv2_integration" "default_http_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "HTTP_PROXY"
  integration_uri        = aws_lb_listener.default_http_listener.arn
  integration_method     = "ANY"
  connection_type        = "VPC_LINK"
  connection_id          = aws_apigatewayv2_vpc_link.vpc_link.id
  payload_format_version = "1.0"
  # CRITICAL: Disables auto-scaling & CodeDeploy
  passthrough_behavior = "WHEN_NO_MATCH"
}

resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.default_http_integration.id}"
}


resource "aws_lb" "internal" {
  name               = local.full_tg_name
  internal           = true
  load_balancer_type = "application"
  security_groups    = [data.terraform_remote_state.security.outputs.lb_sg]

  subnets = data.aws_subnets.private.ids
}

resource "aws_lb_target_group" "default_target_group" {
  name        = local.target_group_name
  port        = var.container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.this.id

  health_check {
    path                = "/health"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    port                = "traffic-port"
    protocol            = "HTTP"
  }
}

resource "aws_lb_listener" "default_http_listener" {
  load_balancer_arn = aws_lb.internal.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default_target_group.arn
  }
}

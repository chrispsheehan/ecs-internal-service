resource "aws_api_gateway_v2_vpc_link" "vpc_link" {
  name        = "${var.service_name}-vpc-link"
  subnet_ids  = data.aws_subnets.private.ids
  security_group_ids = []  # Optional: specify if your ALB has custom SGs
  description = "VPC Link for internal ALB"
}

resource "aws_api_gateway_v2_api" "http_api" {
  name          = "${var.service_name}-http-api"
  protocol_type = "HTTP"
}

resource "aws_api_gateway_v2_integration" "http_integration" {
  api_id           = aws_api_gateway_v2_api.http_api.id
  integration_type = "HTTP_PROXY"
  integration_uri  = "http://${data.aws_lb.internal.dns_name}"
  integration_method = "ANY"
  connection_type  = "VPC_LINK"
  connection_id    = aws_api_gateway_v2_vpc_link.vpc_link.id
  payload_format_version = "1.0"
}

resource "aws_api_gateway_v2_route" "default_route" {
  api_id    = aws_api_gateway_v2_api.http_api.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_api_gateway_v2_integration.http_integration.id}"
}

resource "aws_api_gateway_v2_stage" "default_stage" {
  api_id      = aws_api_gateway_v2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

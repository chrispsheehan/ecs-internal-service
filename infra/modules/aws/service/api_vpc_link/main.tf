resource "aws_apigatewayv2_vpc_link" "vpc_link" {
  name               = "${var.service_name}-vpc-link"
  subnet_ids         = var.private_subnet_ids
  security_group_ids = [var.security_group_id]
}

resource "aws_apigatewayv2_api" "http_api" {
  name          = "${var.service_name}-http-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "http_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "HTTP_PROXY"
  integration_uri        = var.load_balancer_listener_arn
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
  target    = "integrations/${aws_apigatewayv2_integration.http_integration.id}"
}

resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

output "api_id" {
  value = aws_apigatewayv2_api.http_api.id
}

output "vpc_link_id" {
  value = aws_apigatewayv2_vpc_link.vpc_link.id
}

output "load_balancer_arn" {
  value = aws_lb.internal.arn
}

output "api_invoke_url" {
  value = aws_apigatewayv2_stage.default_stage.invoke_url
}
output "api_id" {
  value = aws_apigatewayv2_api.http_api.id
}

output "vpc_link_id" {
  value = aws_apigatewayv2_vpc_link.vpc_link.id
}

output "load_balancer_arn" {
  value = aws_lb.internal.arn
}

output "load_balancer_arn_suffix" {
  value = aws_lb.internal.arn_suffix
}

output "target_group_arn_suffix" {
  value = aws_lb_target_group.default_target_group.arn_suffix
}

output "public_invoke_url" {
  value = trimsuffix(aws_apigatewayv2_stage.default_stage.invoke_url, "/")
}

output "internal_invoke_url" {
  value = "http://${aws_lb.internal.dns_name}"
}

output "default_target_group_arn" {
  value = aws_lb_target_group.default_target_group.arn
}

output "default_http_listener_arn" {
  value = aws_lb_listener.default_http_listener.arn
}

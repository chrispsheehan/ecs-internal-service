output "target_group_arn" {
  value = aws_lb_target_group.ecs.arn
}

output "api_invoke_url" {
  value = module.api_vpc_link.api_invoke_url
}

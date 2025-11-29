output "dns_name" {
  value = aws_lb.internal.dns_name
}

output "target_group_arn_arn" {
  value = aws_lb_target_group.ecs.arn
}

output "dns_name" {
  value = aws_lb.internal.dns_name
}

output "lb_listener_arn" {
  value = aws_lb_listener.http.arn
}

output "target_group_arn" {
  value = aws_lb_target_group.ecs.arn
}

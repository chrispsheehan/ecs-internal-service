output "dns_nam" {
  value = aws_lb.internal.dns_name
}

output "name" {
  value = aws_lb.internal.name
}

output "listener_arn" {
  value = aws_lb_listener.http.arn
}

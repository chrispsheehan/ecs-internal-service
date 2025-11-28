output "dns_name" {
  value = aws_lb.internal.dns_name
}

output "listener_arn" {
  value = aws_lb_listener.http.arn
}

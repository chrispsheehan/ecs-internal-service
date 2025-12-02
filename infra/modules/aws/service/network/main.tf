resource "aws_lb_target_group" "service_target_group" {
  count = local.is_root_path ? 0 : 1

  name        = local.target_group_name
  port        = var.container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

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

resource "aws_lb_listener_rule" "service_path" {
  count = local.is_root_path ? 0 : 1

  listener_arn = var.default_http_listener_arn
  priority     = local.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.service_target_group[0].arn
  }

  condition {
    path_pattern {
      values = ["/${var.service_path}/*"]
    }
  }
}

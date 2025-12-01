resource "aws_apigatewayv2_integration" "http_integration" {
  api_id                 = var.api_id
  integration_type       = "HTTP_PROXY"
  integration_uri        = aws_lb_listener.http.arn
  integration_method     = "ANY"
  connection_type        = "VPC_LINK"
  connection_id          = var.connection_id
  payload_format_version = "1.0"
  # CRITICAL: Disables auto-scaling & CodeDeploy
  passthrough_behavior = "WHEN_NO_MATCH"
}

resource "aws_lb_target_group" "ecs" {
  name        = "${var.service_name}-tg"
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

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.internal.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs.arn
  }
}

resource "aws_iam_role" "ecs_service_role" {
  name               = "${var.service_name}-ecs-service-role"
  description        = "Role used by ECS service for load balancer management"
  assume_role_policy = data.aws_iam_policy_document.ecs_service_assume_role.json
}

resource "aws_iam_policy" "ecs_service_policy" {
  name   = "${var.service_name}-ecs-service-policy"
  policy = data.aws_iam_policy_document.ecs_service_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_service_policy_attachment" {
  role       = aws_iam_role.ecs_service_role.name
  policy_arn = aws_iam_policy.ecs_service_policy.arn
}

resource "aws_ecs_service" "service" {
  name            = var.service_name
  cluster         = data.aws_ecs_cluster.this.id
  task_definition = var.task_definition_arn
  desired_count   = var.desired_task_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    assign_public_ip = false
    security_groups  = [var.security_group_id]
  }

  dynamic "load_balancer" {
    for_each = var.load_balancers
    content {
      target_group_arn = load_balancer.value.target_group_arn
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
    }
  }

  enable_execute_command = var.local_tunnel ? true : false
  wait_for_steady_state  = var.wait_for_steady_state

  # Disable deployment circuit breaker & CodeDeploy
  deployment_circuit_breaker {
    enable   = false
    rollback = false
  }

  deployment_controller {
    type = "ECS"
  }

  depends_on = [aws_iam_service_linked_role.ecs]
}
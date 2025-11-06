locals {
  cloudwatch_log_name = "/ecs/${var.project_name}"
  image_uri           = var.image_uri

  container_definition = [
    {
      name   = var.project_name
      image  = local.image_uri
      cpu    = var.cpu
      memory = var.memory

      portMappings = [
        {
          name          = "${var.project_name}-${var.container_port}-tcp"
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
          appProtocol   = "http"
        }
      ]

      healthcheck = {
        command = [
          "CMD-SHELL",
          "wget --quiet --spider --tries=1 http://localhost:${var.container_port}/health || exit 1"
        ]
        interval     = 5
        retries      = 1
        start_period = 5
        timeout      = 5
      }

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "${local.cloudwatch_log_name}"
          "awslogs-region"        = "${var.aws_region}"
          "awslogs-stream-prefix" = "ecs"
        }
      }

      essential = true
      environment = [
        {
          name  = "IMAGE"
          value = "${local.image_uri}"
        }
      ]

      environmentFiles = []
      mountPoints      = []
      volumesFrom      = []
      ulimits          = []
    }
  ]
}

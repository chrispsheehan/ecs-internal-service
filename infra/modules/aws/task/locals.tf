locals {
  cloudwatch_log_name          = "/ecs/${var.project_name}"
  cloudwatch_otel_log_name     = "/ecs/${var.project_name}/otel"
  image_uri                    = var.image_uri
  aws_otel_collector_image_uri = var.aws_otel_collector_image_uri
  debug_image_uri              = var.debug_image_uri

  shared_environment = [
    {
      name  = "AWS_REGION"
      value = "${var.aws_region}"
    },
    {
      name  = "AWS_SDK_LOAD_CONFIG"
      value = "1"
    }
  ]

  container_definitions = [
    local.api-container,
    local.otel-collector,
    local.debug-container
  ]

  api-container = {
    name        = var.project_name
    networkMode = "awsvpc"
    image       = local.image_uri

    portMappings = [
      {
        name          = "${var.project_name}-${var.container_port}-tcp"
        containerPort = var.container_port
        hostPort      = var.container_port
        protocol      = "tcp"
        appProtocol   = "http"
      }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "${local.cloudwatch_log_name}"
        "awslogs-region"        = "${var.aws_region}"
        "awslogs-stream-prefix" = "ecs"
      }
    }

    essential = true
    environment = concat(local.shared_environment, [
      {
        name  = "IMAGE"
        value = "${local.image_uri}"
      },
      {
        name  = "AWS_XRAY_ENDPOINT"
        value = "http://localhost:4317"
      }
    ])

    command = ["gunicorn", "-k", "uvicorn.workers.UvicornWorker", "--bind", "0.0.0.0:${var.container_port}", "app.app:app"]
  }

  otel-collector = {
    name  = "${var.project_name}-otel-collector"
    image = local.aws_otel_collector_image_uri

    portMappings = [
      {
        name          = "${var.project_name}-otel-collector-${var.container_port}-tcp"
        containerPort = 4317
        hostPort      = 4317
        protocol      = "tcp"
        appProtocol   = "http"
      }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "${local.cloudwatch_otel_log_name}"
        "awslogs-region"        = "${var.aws_region}"
        "awslogs-stream-prefix" = "ecs"
      }
    }

    command = ["--config", "/opt/aws/aws-otel-collector/etc/collector-config.yaml"]

    essential   = false
    environment = local.shared_environment
  }

  debug-container = {
    name  = "${var.project_name}-debug"
    image = local.debug_image_uri

    command = ["sleep", "infinity"]

    essential = false
  }
}

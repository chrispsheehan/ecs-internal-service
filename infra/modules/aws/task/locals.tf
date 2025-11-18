locals {
  cloudwatch_log_name          = "/ecs/${var.project_name}"
  image_uri                    = var.image_uri
  aws_otel_collector_image_uri = "public.ecr.aws/aws-observability/aws-otel-collector:latest"
  collector_config_path        = "${path.module}/collector-config.yaml"

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
    local.api_container,
    local.otel-collector
  ]

  task_volumes = [
    {
      name      = "collector-config"
      host_path = local.collector_config_path
    }
  ]

  api_container = {
    name        = var.project_name
    networkMode = "awsvpc"
    image       = local.image_uri
    cpu         = var.cpu
    memory      = var.memory

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
  }

  otel-collector = {
    name   = "${var.project_name}-otel-collector"
    image  = local.aws_otel_collector_image_uri
    cpu    = var.cpu
    memory = var.memory

    portMappings = [
      {
        name          = "${var.project_name}-otel-collector-${var.container_port}-tcp"
        containerPort = 4317
        hostPort      = 4317
        protocol      = "tcp"
        appProtocol   = "http"
      }
    ]

    mountPoints = [
      {
        sourceVolume  = "collector-config",
        containerPath = "/etc/collector-config.yaml",
        readOnly      = true
      },
    ]

    command = ["--config", "/etc/collector-config.yaml"]

    essential   = false
    environment = local.shared_environment
  }
}

module "task_responder" {
  source = "../_shared/task"

  project_name   = var.project_name
  aws_region     = var.aws_region
  container_port = var.container_port
  cpu            = var.cpu
  memory         = var.memory

  image_uri                    = var.image_uri
  debug_image_uri              = var.debug_image_uri
  aws_otel_collector_image_uri = var.aws_otel_collector_image_uri
  otel_sampling_percentage     = var.otel_sampling_percentage

  local_tunnel = var.local_tunnel
  xray_enabled = var.xray_enabled

  additional_env_vars = [
    {
      "name"  = "DOWNSTREAM_URL",
      "value" = "${var.downstream_url}"
    }
  ]
  additional_runtime_policy_arns = [
    aws_iam_policy.s3_list_policy.arn
  ]

  root_path    = "responder"
  service_name = "ecs-responder-svc"
  python_app   = "app.responder.app:app"
}

resource "aws_iam_policy" "s3_list_policy" {
  name   = "${module.task_responder.service_name}-s3-list-policy"
  policy = data.aws_iam_policy_document.s3_list.json
}

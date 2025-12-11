module "service_consumer" {
  source = "../_shared/service"

  vpc_name   = var.vpc_name
  aws_region = var.aws_region

  state_bucket   = var.state_bucket
  environment    = var.environment
  container_port = var.container_port

  xray_enabled = var.xray_enabled
  local_tunnel = var.local_tunnel

  connection_type     = "internal"
  task_definition_arn = data.terraform_remote_state.task_consumer.outputs.task_definition_arn
  service_name        = data.terraform_remote_state.task_consumer.outputs.service_name

  desired_task_count = 1
  scaling_strategy = {
    cpu = {
      scale_out_threshold  = 70
      scale_in_threshold   = 30
      scale_out_adjustment = 1
      scale_in_adjustment  = 1
      cooldown_out         = 60
      cooldown_in          = 60
    }
  }
}

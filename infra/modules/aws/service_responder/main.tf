module "service_responder" {
  source = "../_shared/service"

  vpc_name   = var.vpc_name
  aws_region = var.aws_region

  state_bucket   = var.state_bucket
  environment    = var.environment
  container_port = var.container_port

  connection_type     = "internal_dns"
  task_definition_arn = data.terraform_remote_state.task_responder.outputs.task_definition_arn
  root_path           = data.terraform_remote_state.task_responder.outputs.root_path
  service_name        = data.terraform_remote_state.task_responder.outputs.service_name
}
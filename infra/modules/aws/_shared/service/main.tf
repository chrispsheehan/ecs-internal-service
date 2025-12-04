module "network" {
  source = "./network"

  count = local.network_count

  vpc_id         = data.aws_vpc.this.id
  service_name   = var.service_name
  root_path      = var.root_path
  container_port = var.container_port

  internal_only = local.internal_only

  api_vpc_link_id           = data.terraform_remote_state.network.outputs.api_id
  default_target_group_arn  = data.terraform_remote_state.network.outputs.default_target_group_arn
  default_http_listener_arn = data.terraform_remote_state.network.outputs.default_http_listener_arn
}

module "ecs" {
  source = "./ecs"

  security_group_ids = concat(
    [data.terraform_remote_state.security.outputs.ecs_sg],
  var.additional_security_group_ids)
  cluster_id          = data.terraform_remote_state.cluster.outputs.cluster_id
  service_name        = var.service_name
  private_subnet_ids  = data.aws_subnets.private.ids
  container_port      = var.container_port
  task_definition_arn = var.task_definition_arn

  xray_enabled = var.xray_enabled
  local_tunnel = var.local_tunnel

  load_balancers = local.load_balancers
}
module "network" {
  source = "./network"

  count = local.network_count

  vpc_id         = data.aws_vpc.this.id
  service_name   = var.service_name
  service_path   = var.service_path
  container_port = var.container_port

  default_target_group_arn  = data.terraform_remote_state.network.outputs.default_target_group_arn
  default_http_listener_arn = data.terraform_remote_state.network.outputs.default_http_listener_arn
}

module "ecs" {
  source = "./ecs"

  security_group_id   = data.terraform_remote_state.security.outputs.ecs_sg
  cluster_id          = data.terraform_remote_state.cluster.outputs.cluster_id
  service_name        = var.service_name
  private_subnet_ids  = data.aws_subnets.private.ids
  container_port      = var.container_port
  task_definition_arn = var.task_definition_arn

  xray_enabled = var.xray_enabled
  local_tunnel = var.local_tunnel

  load_balancers = local.load_balancers
}
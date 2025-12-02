module "network" {
  source = "./network"

  count = local.network_count

  vpc_id         = data.aws_vpc.this.id
  service_name   = var.service_name
  container_port = var.container_port

  load_balancer_arn        = data.terraform_remote_state.network.outputs.load_balancer_arn
  api_id                   = data.terraform_remote_state.network.outputs.api_id
  connection_id            = data.terraform_remote_state.network.outputs.vpc_link_id
  default_target_group_arn = data.terraform_remote_state.network.outputs.default_target_group_arn
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
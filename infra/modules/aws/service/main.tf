# module "security" {
#   source = "./security"

#   vpc_id         = data.aws_vpc.this.id
#   service_name   = var.service_name
#   container_port = var.container_port
# }

# module "load_balancer" {
#   source = "./internal_load_balancer"

#   vpc_id             = data.aws_vpc.this.id
#   security_group_id  = module.security.lb_sg
#   private_subnet_ids = data.aws_subnets.private.ids
#   cluster_name       = var.cluster_name
#   service_name       = var.service_name
#   container_port     = var.container_port
# }

# module "api_vpc_link" {
#   source = "./api_vpc_link"

#   service_name               = var.service_name
#   security_group_id          = module.security.vpc_link_sg
#   load_balancer_listener_arn = module.load_balancer.lb_listener_arn
#   private_subnet_ids         = data.aws_subnets.private.ids
# }

module "network" {
  source = "./network"

  vpc_id         = data.aws_vpc.this.id
  service_name   = var.service_name
  container_port = var.container_port
  api_id         = data.terraform_remote_state.network.outputs.api_id
  connection_id  = data.terraform_remote_state.network.outputs.vpc_link_id
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

  load_balancers = [{
    target_group_arn = module.network.target_group_arn
    container_name   = var.service_name
    container_port   = var.container_port
  }]
}
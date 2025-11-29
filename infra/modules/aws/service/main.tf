module "security" {
  source = "./security"

  vpc_id         = data.aws_vpc.this.id
  service_name   = var.service_name
  container_port = var.container_port
}

module "load_balancer" {
  source = "./internal_load_balancer"

  vpc_id             = data.aws_vpc.this.id
  security_group_id  = module.security.lb_sg
  private_subnet_ids = data.aws_subnets.private.ids
  cluster_name       = var.cluster_name
  service_name       = var.service_name
  container_port     = var.container_port
}

module "api_vpc_link" {
  source = "./api_vpc_link"

  service_name               = var.service_name
  security_group_id          = module.security.vpc_link_sg
  load_balancer_listener_arn = module.load_balancer.listener_arn
  private_subnet_ids         = data.aws_subnets.private.ids
}

module "ecs" {
  source = "./internal_ecs"

  security_group_id   = module.security.ecs_sg
  cluster_name        = var.cluster_name
  service_name        = var.service_name
  private_subnet_ids  = data.aws_subnets.private.ids
  container_port      = var.container_port
  task_definition_arn = var.task_definition_arn

  xray_enabled = var.xray_enabled
  local_tunnel = var.local_tunnel

  load_balancers = [{
    target_group_arn = module.load_balancer.target_group_arn_arn
    container_name   = var.service_name
    container_port   = var.container_port
  }]
}
module "load_balancer" {
  source = "./internal_load_balancer"

  vpc_id             = data.aws_vpc.this.id
  private_subnet_ids = data.aws_subnets.private.ids
  cluster_name       = var.cluster_name
  service_name       = var.service_name
  container_port     = var.container_port
}

module "api_vpc_link" {
  source = "./api_vpc_link"

  load_balancer_name = module.load_balancer.load_balancer_name
  private_subnet_ids = data.aws_subnets.private.ids
}

module "ecs" {
  source = "./internal_ecs"

  cluster_name           = var.cluster_name
  service_name           = var.service_name
  private_subnet_ids     = data.aws_subnets.private.ids
  container_port         = var.container_port
  task_definition_arn    = var.task_definition_arn

  xray_enabled = var.xray_enabled
  local_tunnel = var.local_tunnel

  load_balancers = [ {
    target_group_arn = module.load_balancer.listener_arn
    container_name   = var.service_name
    container_port   = var.container_port
  }]
}
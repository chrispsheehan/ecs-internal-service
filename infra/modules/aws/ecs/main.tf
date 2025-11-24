resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"
}

resource "aws_security_group" "vpc_endpoint" {
  name        = "${var.project_name}-vpc-endpoint-sg"
  description = "Security group for VPC endpoints"
  vpc_id      = data.aws_vpc.this.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.this.cidr_block]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.this.cidr_block]
  }
}

resource "aws_vpc_endpoint" "interface_endpoints" {
  for_each            = local.interface_endpoints
  vpc_id              = data.aws_vpc.this.id
  service_name        = "com.amazonaws.${var.aws_region}.${each.value}"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.vpc_endpoint.id]
  subnet_ids          = data.aws_subnets.private.ids
  private_dns_enabled = lookup(local.private_dns_overrides, each.key, true)
}

resource "aws_vpc_endpoint" "gateway_s3" {
  vpc_id            = data.aws_vpc.this.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = data.aws_route_tables.subnet_route_tables.ids
}

resource "aws_security_group" "ecs_service" {
  name        = "${var.project_name}-ecs-sg"
  description = "ECS service private access only"
  vpc_id      = data.aws_vpc.this.id

  # Allow inbound traffic from within the VPC
  ingress {
    description = "Allow traffic within VPC"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.this.cidr_block]
  }

  # Allow all outbound (for API calls, updates, etc.)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_service" "service" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = var.task_definition_arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.private.ids
    assign_public_ip = false
    security_groups  = [aws_security_group.ecs_service.id]
  }

  enable_execute_command = var.local_tunnel ? true : false
  wait_for_steady_state  = var.wait_for_steady_state
}
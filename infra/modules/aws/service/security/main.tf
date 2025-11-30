resource "aws_security_group" "vpc_link_sg" {
  name_prefix = "${var.service_name}-vpc-link"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "egress_vpc_link_to_lb" {
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.vpc_link_sg.id
  source_security_group_id = aws_security_group.lb_sg.id
}

resource "aws_security_group" "lb_sg" {
  name_prefix = "${var.service_name}-vpc-link-lb"
  vpc_id      = var.vpc_id
  description = "Security group for internal ALB/NLB accessible via VPC Link"
}

resource "aws_security_group_rule" "ingress_vpc_link_to_lb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.lb_sg.id
  source_security_group_id = aws_security_group.vpc_link_sg.id
}

# resource "aws_security_group_rule" "egress_lb_to_internet" {
#   type              = "egress"
#   from_port         = 0
#   to_port           = 0
#   protocol          = "-1"
#   cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.lb_sg.id
# }

resource "aws_security_group" "ecs_sg" {
  name_prefix = "${var.service_name}-ecs-fargate"
  vpc_id      = var.vpc_id
  description = "ECS Fargate tasks"
}

resource "aws_security_group_rule" "ingress_lb_to_ecs" {
  type                     = "ingress"
  from_port                = var.container_port
  to_port                  = var.container_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs_sg.id
  source_security_group_id = aws_security_group.lb_sg.id
}

resource "aws_security_group_rule" "egress_ecs_to_internet" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecs_sg.id
}

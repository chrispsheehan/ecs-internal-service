locals {
  aws_region = "eu-west-2"
  vpc_name   = "vpc"
  allowed_role_actions = [
    "s3:*",
    "iam:*",
    "ecr:*",
    "ecs:*",
    "ec2:*",
    "logs:*",
    "cloudwatch:*",
    "elasticloadbalancing:*",
    "apigateway:*"
  ]
  container_port = 3000
}

inputs = {
  vpc_name             = local.vpc_name
  aws_region           = local.aws_region
  allowed_role_actions = local.allowed_role_actions
  container_port       = local.container_port
}
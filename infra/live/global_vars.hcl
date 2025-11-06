locals {
  aws_region = "eu-west-2"
  allowed_role_actions = [
    "s3:*",
    "iam:*",
    "ecr:*",
    "ecs:*",
    "ec2:*",
    "logs:*",
    "cloudwatch:*"
  ]
  container_port = 3000
}

inputs = {
  aws_region           = local.aws_region
  allowed_role_actions = local.allowed_role_actions
  container_port       = local.container_port
}
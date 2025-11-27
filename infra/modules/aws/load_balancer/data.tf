data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = ["vpc"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }

  filter {
    name   = "tag:Name"
    values = ["*private*"]
  }
}

data "aws_ecs_cluster" "main" {
  cluster_name = "${var.project_name}-cluster"
}
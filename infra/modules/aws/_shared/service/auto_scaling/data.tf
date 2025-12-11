data "aws_ecs_cluster" "cluster" {
  cluster_name = "${var.project_name}-cluster"
}

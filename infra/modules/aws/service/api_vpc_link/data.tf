data "aws_lb" "this" {
  name = var.load_balancer_name
}
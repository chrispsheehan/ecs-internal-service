data "terraform_remote_state" "task_caller" {
  backend = "s3"

  config = {
    bucket = var.state_bucket
    key    = "${var.environment}/aws/task_caller/terraform.tfstate"
    region = var.aws_region
  }
}
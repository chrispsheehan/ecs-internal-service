data "terraform_remote_state" "task_responder" {
  backend = "s3"

  config = {
    bucket = var.state_bucket
    key    = "${var.environment}/aws/task_responder/terraform.tfstate"
    region = var.aws_region
  }
}
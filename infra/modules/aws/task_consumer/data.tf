data "terraform_remote_state" "sqs_consumer" {
  backend = "s3"

  config = {
    bucket = var.state_bucket
    key    = "${var.environment}/aws/sqs_consumer/terraform.tfstate"
    region = var.aws_region
  }
}
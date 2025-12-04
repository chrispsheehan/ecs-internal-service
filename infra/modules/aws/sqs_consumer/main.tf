module "sqs_consumer" {
  source = "../_shared/sqs"

  sqs_queue_name = "internal-sqs-queue"
}
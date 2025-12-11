output "sqs_queue_name" {
  value = module.sqs_consumer.sqs_queue_name
}

output "sqs_queue_url" {
  value = module.sqs_consumer.sqs_queue_url
}

output "sqs_queue_read_policy_arn" {
  value = module.sqs_consumer.sqs_queue_read_policy_arn
}

output "sqs_queue_write_policy_arn" {
  value = module.sqs_consumer.sqs_queue_write_policy_arn
}

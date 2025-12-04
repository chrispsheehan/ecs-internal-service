output "sqs_queue_url" {
  value = aws_sqs_queue.queue.url
}

output "sqs_queue_read_write_policy_arn" {
  value = aws_iam_policy.queue_read_write_policy.arn
}

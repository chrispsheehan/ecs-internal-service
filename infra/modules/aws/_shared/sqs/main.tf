resource "aws_sqs_queue" "queue" {
  name                      = var.sqs_queue_name
  delay_seconds             = 0
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
}

resource "aws_iam_policy" "queue_read_write_policy" {
  name   = "${var.sqs_queue_name}-sqs-read-write-policy"
  policy = data.aws_iam_policy_document.sqs_read_write.json
}

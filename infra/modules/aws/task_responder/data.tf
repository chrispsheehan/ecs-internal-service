data "aws_iam_policy_document" "s3_list" {
  statement {
    actions = [
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
}

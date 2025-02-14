# – IAM –

resource "aws_iam_role" "sg_endpoint_role" {
  count              = var.sg_role_arn == null ? 1 : 0
  assume_role_policy = data.aws_iam_policy_document.sg_trust[0].json
  name_prefix        = var.name_prefix
}

resource "aws_iam_role_policy_attachment" "sg_policy_attachment" {
  count      = var.sg_role_arn == null ? 1 : 0
  role       = aws_iam_role.sg_endpoint_role[0].name
  policy_arn = data.aws_iam_policy.sg_full_access.arn
}
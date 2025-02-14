# – DATA –

#data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
#data "aws_region" "current" {}

locals {
  #  region     = data.aws_region.current.name
  #  account_id = data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition
  dns_suffix = data.aws_partition.current.dns_suffix
}

data "aws_iam_policy_document" "sg_trust" {
  count = var.sg_role_arn == null ? 1 : 0
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["sagemaker.${local.dns_suffix}"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy" "sg_full_access" {
  arn = "arn:${local.partition}:iam::aws:policy/AmazonSageMakerFullAccess"
}

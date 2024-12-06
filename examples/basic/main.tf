#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################
variable "region" {
  type        = string
  description = "AWS region to deploy the resources"
  default     = "us-east-1"
}

provider "aws" {
  region = var.region
}

module "sagemaker-endpoint" {
    source = "../.."
    endpoint_name = "mistralendpoint"
    containers = [ {
      image_uri = "763104351884.dkr.ecr.${var.region}.amazonaws.com/huggingface-pytorch-tgi-inference:2.0.1-tgi1.1.0-gpu-py39-cu118-ubuntu20.04"
      environment = {
        "SM_NUM_GPUS" = 1
        "MAX_INPUT_LENGTH" = 2048
        "MAX_TOTAL_TOKENS" = 4096
        "HF_API_TOKEN" = "XXX"
      }
    } ]
    production_variant = {
        variant_name = "AllTraffic"
        instance_type = "ml.g5.2xl"
    }
}
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
      image_uri = "763104351884.dkr.ecr.${var.region}.amazonaws.com/huggingface-pytorch-tgi-inference:2.4.0-tgi2.4.0-gpu-py311-cu124-ubuntu22.04"
      environment = {
        "HF_MODEL_ID" = "mistralai/Mistral-7B-Instruct-v0.1"
        "SM_NUM_GPUS" = 1
        "MAX_INPUT_LENGTH" = 2048
        "MAX_TOTAL_TOKENS" = 4096
        "HF_API_TOKEN" = "XXXXX"
      }
    } ]
    production_variant = {
        variant_name = "AllTraffic"
        instance_type = "ml.g5.2xlarge"
        initial_instance_count=1
    }
    #checkov:skip=CKV_AWS_370:The container will pull the model artifacts from HF
    enable_network_isolation = false
}
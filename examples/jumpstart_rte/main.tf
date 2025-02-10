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
    endpoint_name = "llamatwo"
    containers = [ {
      model_package_name = "arn:aws:sagemaker:us-east-1:865070037744:model-package/llama2-7b-f-v4-71eeccf76ddf33f2a18d2e16b9c7f302"
    } ]
    production_variant = {
        variant_name = "AllTraffic"
        instance_type = "ml.g5.2xlarge"
        initial_instance_count=1
        container_startup_health_check_timeout_in_seconds=600
    }
    enable_network_isolation = true
}
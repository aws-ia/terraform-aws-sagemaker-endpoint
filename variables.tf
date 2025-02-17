# – VARIABLES –

variable "name_prefix" {
  description = "This value is appended at the beginning of resource names."
  type        = string
  default     = "SGTFendpoint"
}

variable "sg_role_arn" {
  description = "The ARN of the IAM role with permission to access model artifacts and docker images for deployment."
  type        = string
  default     = null
}

variable "endpoint_name" {
  description = "The name of the Amazon SageMaker Endpoint."
  type        = string
  default     = "SGendpoint"
}

variable "tags" {
  description = "Tag the Amazon SageMaker Endpoint resource."
  type        = map(string)
  default     = null
}

variable "enable_network_isolation" {
  description = "Isolates the model container. No inbound or outbound network calls can be made to or from the model container."
  type        = bool
  default     = false
}

variable "containers" {
  description = "Specifies the container definitions for this SageMaker model, consisting of either a single primary container or an inference pipeline of multiple containers."
  type = list(object({
    image_uri          = optional(string)
    model_package_name = optional(string)
    model_data_url     = optional(string)
    mode               = optional(string, "SingleModel")
    environment        = optional(map(string))
    container_hostname = optional(string)
    image_config = optional(object({
      repository_access_mode = string
      repository_auth_config = optional(object({
        repository_credentials_provider_arn = string
      }))
    }))
    inference_specification_name = optional(string)
    model_data_source = optional(object({
      s3_data_type  = string
      s3_uri        = string
      is_compressed = optional(bool)
      accept_eula   = optional(bool)
    }))
    multi_model_config = optional(object({
      model_cache_setting = optional(string)
    }))
  }))
  default = []

  validation {
    condition = alltrue([
      for container in var.containers :
      container.mode == null || contains(["SingleModel", "MultiModel"], container.mode)
    ])
    error_message = "The mode parameter must be either 'SingleModel' or 'MultiModel'."
  }

  validation {
    condition     = length(var.containers) <= 15
    error_message = "The number of containers must not exceed 15."
  }
}

variable "production_variant" {
  description = "Configuration for the production variant of the SageMaker endpoint."
  type = object({
    accelerator_type                                  = optional(string)
    container_startup_health_check_timeout_in_seconds = optional(number)
    core_dump_config = optional(object({
      destination_s3_uri = string
      kms_key_id         = optional(string)
    }))
    enable_ssm_access                      = optional(bool)
    inference_ami_version                  = optional(string)
    initial_instance_count                 = optional(number)
    instance_type                          = optional(string)
    model_data_download_timeout_in_seconds = optional(number)
    variant_name                           = optional(string, "AllTraffic")
    volume_size_in_gb                      = optional(number)
  })
  default = ({
    initial_instance_count                 = 1
    instance_type                          = "ml.t2.medium"
    model_data_download_timeout_in_seconds = 900
    variant_name                           = "AllTraffic"
    volume_size_in_gb                      = 30
  })
}

variable "kms_key_arn" {
  description = "Amazon Resource Name (ARN) of a AWS Key Management Service key that Amazon SageMaker uses to encrypt data on the storage volume attached to the ML compute instance that hosts the endpoint."
  type        = string
  default     = null
}

variable "autoscaling_config" {
  description = "Enable autoscaling for the SageMaker Endpoint production variant."
  type = object({
    min_capacity       = optional(number, 1)
    max_capacity       = number
    target_value       = number
    scale_in_cooldown  = optional(number)
    scale_out_cooldown = optional(number)
  })
  default = null
}








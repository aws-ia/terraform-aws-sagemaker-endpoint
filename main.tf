# – MAIN –

resource "random_string" "solution_suffix" {
  length  = 4
  special = false
  upper   = false
}

# – SageMaker model –

resource "aws_sagemaker_model" "sagemaker_model" {
  name               = "${var.name_prefix}-model-${random_string.solution_suffix.result}"
  execution_role_arn = aws_iam_role.sg_endpoint_role[0].arn

  dynamic "primary_container" {
    for_each = length(var.containers) == 1 ? [var.containers[0]] : []
    content {
      image              = primary_container.value.image_uri
      model_package_name = primary_container.value.model_package_name
      model_data_url     = primary_container.value.model_data_url
      mode               = primary_container.value.mode
      environment        = primary_container.value.environment
      container_hostname = primary_container.value.container_hostname

      dynamic "image_config" {
        for_each = primary_container.value.image_config != null ? [primary_container.value.image_config] : []
        content {
          repository_access_mode = image_config.value.repository_access_mode
          dynamic "repository_auth_config" {
            for_each = image_config.value.repository_auth_config != null ? [image_config.value.repository_auth_config] : []
            content {
              repository_credentials_provider_arn = repository_auth_config.value.repository_credentials_provider_arn
            }
          }
        }
      }

      dynamic "model_data_source" {
        for_each = primary_container.value.model_data_source != null ? [primary_container.value.model_data_source] : []
        content {
          s3_data_source {
            s3_data_type    = model_data_source.value.s3_data_type
            s3_uri          = model_data_source.value.s3_uri
            compression_type = model_data_source.value.is_compressed == true ? "Gzip" : "None"
            model_access_config {
                accept_eula = model_data_source.value.accept_eula
            }
          }
        }
      }

      dynamic "multi_model_config" {
        for_each = primary_container.value.multi_model_config != null ? [primary_container.value.multi_model_config] : []
        content {
          model_cache_setting = multi_model_config.value.model_cache_setting
        }
      }
    }
  }

  dynamic "container" {
    for_each = length(var.containers) > 1 ? var.containers : []
    content {
      image              = container.value.image_uri
      model_package_name = container.value.model_package_name
      model_data_url     = container.value.model_data_url
      mode               = container.value.mode
      environment        = container.value.environment
      container_hostname = container.value.container_hostname

      dynamic "image_config" {
        for_each = container.value.image_config != null ? [container.value.image_config] : []
        content {
          repository_access_mode = image_config.value.repository_access_mode
          dynamic "repository_auth_config" {
            for_each = image_config.value.repository_auth_config != null ? [image_config.value.repository_auth_config] : []
            content {
              repository_credentials_provider_arn = repository_auth_config.value.repository_credentials_provider_arn
            }
          }
        }
      }

      dynamic "model_data_source" {
        for_each = container.value.model_data_source != null ? [container.value.model_data_source] : []
        content {
          s3_data_source {
            s3_data_type    = model_data_source.value.s3_data_type
            s3_uri          = model_data_source.value.s3_uri
            compression_type = model_data_source.value.is_compressed == true ? "Gzip" : "None"
            model_access_config {
                accept_eula = model_data_source.value.accept_eula
            }
          }
        }
      }

      dynamic "multi_model_config" {
        for_each = container.value.multi_model_config != null ? [container.value.multi_model_config] : []
        content {
          model_cache_setting = multi_model_config.value.model_cache_setting
        }
      }
    }
  }
  enable_network_isolation = var.enable_network_isolation
  tags = var.tags
}

# – SageMaker endpoint configuration –

resource "aws_sagemaker_endpoint_configuration" "sagemaker_endpoint_config" {
  name = "${var.name_prefix}-config-${random_string.solution_suffix.result}"

  production_variants {
    accelerator_type                              = var.production_variant.accelerator_type
    container_startup_health_check_timeout_in_seconds = var.production_variant.container_startup_health_check_timeout_in_seconds
    dynamic "core_dump_config" {
      for_each = var.production_variant.core_dump_config != null ? [var.production_variant.core_dump_config] : []
      content {
        destination_s3_uri = core_dump_config.value.destination_s3_uri
        kms_key_id        = core_dump_config.value.kms_key_id
      }
    }
    enable_ssm_access                             = var.production_variant.enable_ssm_access
    inference_ami_version                         = var.production_variant.inference_ami_version
    initial_instance_count                        = var.production_variant.initial_instance_count
    instance_type                                 = var.production_variant.instance_type
    model_data_download_timeout_in_seconds        = var.production_variant.model_data_download_timeout_in_seconds
    model_name                                    = aws_sagemaker_model.sagemaker_model.name
    variant_name                                  = var.production_variant.variant_name
    volume_size_in_gb                             = var.production_variant.volume_size_in_gb
    initial_variant_weight                        = 1.0
  }

  kms_key_arn = var.kms_key_arn
  tags = var.tags
}

# – SageMaker endpoint –

resource "aws_sagemaker_endpoint" "sagemaker_endpoint" {
  name                    = var.endpoint_name
  endpoint_config_name    = aws_sagemaker_endpoint_configuration.sagemaker_endpoint_config.name
  tags                    = var.tags
}

# – AutoScaling –

resource "aws_appautoscaling_target" "sagemaker_target" {
  count              = var.autoscaling_config != null ? 1 : 0
  max_capacity       = var.autoscaling_config.max_capacity
  min_capacity       = var.autoscaling_config.min_capacity
  resource_id        = "endpoint/${aws_sagemaker_endpoint.sagemaker_endpoint.name}/variant/${var.production_variant.variant_name}"
  scalable_dimension = "sagemaker:variant:DesiredInstanceCount"
  service_namespace  = "sagemaker"
}

resource "aws_appautoscaling_policy" "sagemaker_policy" {
  count              = var.autoscaling_config != null ? 1 : 0
  name               = "SageMakerEndpointInvocationScalingPolicy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.sagemaker_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.sagemaker_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.sagemaker_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = var.autoscaling_config.target_value
    scale_in_cooldown = var.autoscaling_config.scale_in_cooldown
    scale_out_cooldown = var.autoscaling_config.scale_out_cooldown

    predefined_metric_specification {
      predefined_metric_type = "SageMakerVariantInvocationsPerInstance"
    }
  }
}


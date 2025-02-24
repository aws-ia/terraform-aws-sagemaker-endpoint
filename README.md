<!-- BEGIN_TF_DOCS -->
# Terraform Amazon SageMaker Endpoint Module

<!-- markdownlint-disable MD012 -->
This module includes resources to deploy Amazon SageMaker endpoints. It takes care of creating a SageMaker model, SageMaker endpoint configuration, and the SageMaker endpoint.

With Amazon SageMaker, you can start getting predictions, or inferences, from your trained machine learning models. SageMaker provides a broad selection of ML infrastructure and model deployment options to help meet all your ML inference needs. With SageMaker Inference, you can scale your model deployment, manage models more effectively in production, and reduce operational burden.

This module supports the following ways to deploy a model, depending on your use case:

- For persistent, real-time endpoints that make one prediction at a time, use SageMaker real-time hosting services. Real-time inference is ideal for inference workloads where you have real-time, interactive, low latency requirements. You can deploy your model to SageMaker hosting services and get an endpoint that can be used for inference. These endpoints are fully managed and support autoscaling.
- For requests with large payload sizes up to 1GB, long processing times, and near real-time latency requirements, use Amazon SageMaker Asynchronous Inference. Amazon SageMaker Asynchronous Inference is a capability in SageMaker that queues incoming requests and processes them asynchronously. This option is ideal for requests with large payload sizes (up to 1GB), long processing times (up to one hour), and near real-time latency requirements. Asynchronous Inference enables you to save on costs by autoscaling the instance count to zero when there are no requests to process, so you only pay when your endpoint is processing requests.

## Model configuration

### Single container

In the event that a single container is sufficient for your inference use-case, you can define a single-container model.

### Inference pipeline

An inference pipeline is an Amazon SageMaker model that is composed of a linear sequence of multiple containers that process requests for inferences on data. See the [AWS documentation](https://docs.aws.amazon.com/sagemaker/latest/dg/inference-pipelines.html) to learn more about SageMaker inference pipelines. To define an inference pipeline, you can provide additional containers for your model.

### Network isolation

If you enable network isolation, the containers can't make any outbound network calls, even to other AWS services such as Amazon Simple Storage Service (S3). Additionally, no AWS credentials are made available to the container runtime environment.

To enable network isolation, set the ***enable\_network\_isolation*** property to true.

### Container images

#### ECR Image

Reference an image available within ECR

### DLC Image

Reference an [AWS Deep Learning Container](https://docs.aws.amazon.com/deep-learning-containers/latest/devguide/what-is-dlc.html) image.

### Model artifacts

If you choose to decouple your model artifacts from your inference code (as is natural given different rates of change between inference code and model artifacts), the artifacts can be specified via the model\_data\_source property of var.containers. The default is to have no model artifacts associated with a model. For instance: model\_data\_source=s3://{bucket\_name}/{key\_name}/model.tar.gz

## Model hosting

Amazon SageMaker provides model hosting services for model deployment. Amazon SageMaker provides an HTTPS endpoint where your machine learning model is available to provide inferences.

### Endpoint configuration

### Endpoint

When this module creates an endpoint, Amazon SageMaker launches the ML compute instances and deploys the model as specified in the configuration. To get inferences from the model, client applications send requests to the Amazon SageMaker Runtime HTTPS endpoint.

#### Real-time inference endpoints

Real-time inference is ideal for inference workloads where you have real-time, interactive, low latency requirements. You can deploy your model to SageMaker AI hosting services and get an endpoint that can be used for inference. These endpoints are fully managed and support autoscaling.

#### Asynchronous inference endpoints

Coming soon

### AutoScaling

To enable autoscaling on the production variant, use the autoscaling\_config variable. For load testing guidance on determining the maximum requests per second per instance, please see this [documentation](https://docs.aws.amazon.com/sagemaker/latest/dg/endpoint-scaling-loadtest.html).

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~>5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~>5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_appautoscaling_policy.sagemaker_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_target.sagemaker_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_iam_role.sg_endpoint_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.sg_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_sagemaker_endpoint.sagemaker_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sagemaker_endpoint) | resource |
| [aws_sagemaker_endpoint_configuration.sagemaker_endpoint_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sagemaker_endpoint_configuration) | resource |
| [aws_sagemaker_model.sagemaker_model](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sagemaker_model) | resource |
| [random_string.solution_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_iam_policy.sg_full_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_iam_policy_document.sg_trust](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_autoscaling_config"></a> [autoscaling\_config](#input\_autoscaling\_config) | Enable autoscaling for the SageMaker Endpoint production variant. | <pre>object({<br>    min_capacity       = optional(number, 1)<br>    max_capacity       = number<br>    target_value       = number<br>    scale_in_cooldown  = optional(number)<br>    scale_out_cooldown = optional(number)<br>  })</pre> | `null` | no |
| <a name="input_containers"></a> [containers](#input\_containers) | Specifies the container definitions for this SageMaker model, consisting of either a single primary container or an inference pipeline of multiple containers. | <pre>list(object({<br>    image_uri          = optional(string)<br>    model_package_name = optional(string)<br>    model_data_url     = optional(string)<br>    mode               = optional(string, "SingleModel")<br>    environment        = optional(map(string))<br>    container_hostname = optional(string)<br>    image_config = optional(object({<br>      repository_access_mode = string<br>      repository_auth_config = optional(object({<br>        repository_credentials_provider_arn = string<br>      }))<br>    }))<br>    inference_specification_name = optional(string)<br>    model_data_source = optional(object({<br>      s3_data_type  = string<br>      s3_uri        = string<br>      is_compressed = optional(bool)<br>      accept_eula   = optional(bool)<br>    }))<br>    multi_model_config = optional(object({<br>      model_cache_setting = optional(string)<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_enable_network_isolation"></a> [enable\_network\_isolation](#input\_enable\_network\_isolation) | Isolates the model container. No inbound or outbound network calls can be made to or from the model container. | `bool` | `false` | no |
| <a name="input_endpoint_name"></a> [endpoint\_name](#input\_endpoint\_name) | The name of the Amazon SageMaker Endpoint. | `string` | `"SGendpoint"` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | Amazon Resource Name (ARN) of a AWS Key Management Service key that Amazon SageMaker uses to encrypt data on the storage volume attached to the ML compute instance that hosts the endpoint. | `string` | `null` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | This value is appended at the beginning of resource names. | `string` | `"SGTFendpoint"` | no |
| <a name="input_production_variant"></a> [production\_variant](#input\_production\_variant) | Configuration for the production variant of the SageMaker endpoint. | <pre>object({<br>    accelerator_type                                  = optional(string)<br>    container_startup_health_check_timeout_in_seconds = optional(number)<br>    core_dump_config = optional(object({<br>      destination_s3_uri = string<br>      kms_key_id         = optional(string)<br>    }))<br>    enable_ssm_access                      = optional(bool)<br>    inference_ami_version                  = optional(string)<br>    initial_instance_count                 = optional(number)<br>    instance_type                          = optional(string)<br>    model_data_download_timeout_in_seconds = optional(number)<br>    variant_name                           = optional(string, "AllTraffic")<br>    volume_size_in_gb                      = optional(number)<br>  })</pre> | <pre>{<br>  "initial_instance_count": 1,<br>  "instance_type": "ml.t2.medium",<br>  "model_data_download_timeout_in_seconds": 900,<br>  "variant_name": "AllTraffic",<br>  "volume_size_in_gb": 30<br>}</pre> | no |
| <a name="input_sg_role_arn"></a> [sg\_role\_arn](#input\_sg\_role\_arn) | The ARN of the IAM role with permission to access model artifacts and docker images for deployment. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tag the Amazon SageMaker Endpoint resource. | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_sagemaker_endpoint_config_name"></a> [sagemaker\_endpoint\_config\_name](#output\_sagemaker\_endpoint\_config\_name) | The name of the SageMaker endpoint configuration |
| <a name="output_sagemaker_endpoint_name"></a> [sagemaker\_endpoint\_name](#output\_sagemaker\_endpoint\_name) | The name of the SageMaker endpoint |
| <a name="output_sagemaker_role_arn"></a> [sagemaker\_role\_arn](#output\_sagemaker\_role\_arn) | The ARN of the IAM role for the SageMaker endpoint |
<!-- END_TF_DOCS -->
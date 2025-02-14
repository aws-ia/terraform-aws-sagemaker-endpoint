<!-- BEGIN_TF_DOCS -->
# SageMaker JumpStart real-time endpoint deployment

<!-- markdownlint-disable MD024 -->
This sample demonstrates how to deploy and interact with a model available on Amazon SageMaker JumpStart.

Specifically, this sample deploys a SageMaker real-time endpoint, hosting Llama 2 7B v2.0.2.

> **Warning**
> Amazon SageMaker JumpStart provides access to both publicly available and proprietary foundation models. Foundation models are onboarded and maintained from third-party open source and proprietary providers. As such, they are released under different licenses as designated by the model source. Be sure to review the license for any foundation model that you use. You are responsible for reviewing and complying with any applicable license terms and making sure they are acceptable for your use case before downloading or using the content.
>
> Similarly, for any proprietary foundation models, be sure to review and comply with any terms of use and usage guidelines from the model provider. If you have questions about license information for a specific
> proprietary model, reach out to model provider directly. You can find model provider contact information in the Support tab of each model page in AWS Marketplace. To explore the latest proprietary foundation
> models, see Getting started with [Amazon SageMaker JumpStart](http://aws.amazon.com/sagemaker/jumpstart/getting-started/?sagemaker-jumpstart-cards.sort-by=item.additionalFields.priority&sagemaker-jumpstart-cards.sort-order=asc&awsf.sagemaker-jumpstart-filter-product-type=product-type%23foundation-model&awsf.sagemaker-jumpstart-filter-text=*all&awsf.sagemaker-jumpstart-filter-vision=*all&awsf.sagemaker-jumpstart-filter-tabular=*all&awsf.sagemaker-jumpstart-filter-audio-tasks=*all&awsf.sagemaker-jumpstart-filter-multimodal=*all&awsf.sagemaker-jumpstart-filter-RL=*all&sagemaker-jumpstart-cards.q=proprietary&sagemaker-jumpstart-cards.q_operator=AND).

## Prerequisites

An AWS account. We recommend you deploy this solution in a new account.

- AWS CLI: configure your credentials

```
aws configure --profile [your-profile]
AWS Access Key ID [None]: xxxxxx
AWS Secret Access Key [None]:yyyyyyyyyy
Default region name [None]: us-east-1
Default output format [None]: json
```

- Terraform: v1.9.8 or greater
- Make sure you have sufficient quota for the instance type implemented in this sample (service Amazon SageMaker, instance type ml.g5.2xlarge for endpoint usage). For more information, refer to [AWS service quotas](https://docs.aws.amazon.com/general/latest/gr/aws_service_limits.html).

## Deploy

This project is built using [Terraform](https://www.terraform.io/). See [Getting Started - AWS](https://developer.hashicorp.com/terraform/tutorials/aws-get-started) for additional details and prerequisites.

```shell
git clone https://github.com/aws-ia/terraform-aws-sagemaker-endpoint.git
```

2. Enter the code sample backend directory.

```shell
cd examples/jumpstart_rte
```

3. Initialize the neccessary Terraform providers

```shell
terraform init
```

4. Check the plan.

```shell
terraform plan
```

6. Deploy the sample in your account.

```shell
terraform apply
```

With the default configuration of this sample, the observed deployment time was ~7minutes 30s.

To protect you against unintended changes that affect your security posture, the Terraform prompts you to approve before deploying them. You will need to answer ***yes*** to get the solution deployed.

![Llama Jumpstart](./docs/jumpstart\_model.png)

## Test

You can then invoke the provisioned endpoint. For instance, we show here an example using [boto3](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/sagemaker-runtime/client/invoke_endpoint.html) in Python.

```python
import boto3
import json
import os

ENDPOINT_NAME = 'llamatwo'
runtime= boto3.client('runtime.sagemaker')

dic = {
    "inputs": [
    [
    {"role": "system", "content": "You are chat bot who writes songs"},
    {"role": "user", "content": "Write a rap song about Amazon Web Services"}
    ]
    ],
    "parameters": {"max_new_tokens":256, "top_p":0.9, "temperature":0.6}
}

response = runtime.invoke_endpoint(EndpointName=ENDPOINT_NAME,
                                    ContentType='application/json',
                                    Body=json.dumps(dic),
                                    CustomAttributes="accept_eula=true")

result = json.loads(response['Body'].read().decode())
print(result)

return {
    "statusCode": 200,
    "body": json.dumps(result)
}
```

Example of output:

```
{
  "statusCode": 200,
  "body": "[{\"generation\": {\"role\": \"assistant\", \"content\": \" (Verse 1)\\nYo, listen up, I got a story to tell\\n'Bout a cloud service that's off the bell\\nAmazon Web Services, the king of the game\\nProviding the infrastructure, ain't no one the same\\n\\nFrom EC2 to S3, they got it all\\nScalable and secure, standing tall\\nMaking sure your apps and data stay safe\\nAWS, the leader in the tech race\\n\\n(Chorus)\\nAWS, AWS, the cloud service supreme\\nMaking sure your digital dreams come true\\nFrom the ground up, they'll help you grow\\nAWS, the cloud that'll help you flow\\n\\n(Verse 2)\\nFrom storage to analytics, they got the tools\\nMaking sure your app is always in the mood\\nDynamoDB and Redshift, they're on the rise\\nAWS, the choice for data that never dies\\n\\nFrom serverless to machine learning\\nAWS, the king of the cloud is revealing\\nTheir services are second to none\\nMaking sure your app is number one\\n\\n(Chorus)\\nAWS,\"}}]"
}
```

## Clean up

```shell
terraform destroy
```

Delete all the associated logs created by the different services in Amazon CloudWatch logs.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~>5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.6.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_sagemaker-endpoint"></a> [sagemaker-endpoint](#module\_sagemaker-endpoint) | ../.. | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_region"></a> [region](#input\_region) | AWS region to deploy the resources | `string` | `"us-east-1"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
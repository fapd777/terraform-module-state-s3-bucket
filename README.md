<!-- BEGIN_TF_DOCS -->

# terraform-module-state-s3-bucket

This repository holds a Terraform module that creates:

* An S3 bucket for storing Terraform state.
* A Dynamo DB table to avoid Terraform state writing conflict for multiple users.
* A KMS key used by Dynamo DB.

Follow the next steps to set up the S3 bucket for the remote Terraform state in the caller Terraform repository:

## 1. Create the s3-bucket-tfstate.tf file:

Create an s3-bucket-tfstate.tf file in the Terraform root directory with the following configuration:

```hcl
################################################################################
# Terraform Remote State Amazon S3 Bucket
################################################################################

module "terraform_state" {
  source        = "git::https://github.com/fapd777/terraform-module-state-s3-bucket.git"
  name_prefix   = var.name_prefix
  name_suffix   = var.region
  log_bucket_id = var.logging_bucket
}
```
You can create an S3 bucket for logging purposes using the following Terraform module:  
https://github.com/fapd777/terraform-module-s3-bucket-logging

## 2. Execute Terraform apply to create the S3 bucket, Dynamo DB table, and KMS key:

```bash
terraform apply -var-file ./apply-tfvars/dev.tfvars
```
## 3. Keep a record of the following outputs resulting from Terraform applying the module:

```hcl
terraform_state_bucket = "aws-s3-service-remote-state-backend-us-east-2"
terraform_state_config_s3_key = "aws-s3-service-dev-remote-state-backend.tfstate"
terraform_state_dynamodb_table = "aws-s3-service-remote-state-backend-us-east-2"
terraform_state_kms_key_arn = "arn:aws:kms:us-east-2:1234567890AB:key/12345678-90AB-CDEF-GHIJ-KLMNOPQRSTYWXYZ"
```

## 4. Create the init-tfvars/dev.tfvars and state.tf files:

Use the outputs from the previous step to create a dev.tfvars file in the Terraform init-tfvars directory with the following configuration:

```hcl
# These variables are called when running the following command:
# terraform init -backend-config=./init-tfvars/dev.tfvars
bucket         = "aws-s3-service-remote-state-backend-us-east-2"
key            = "aws-s3-service-dev-remote-state-backend.tfstate"
dynamodb_table = "aws-s3-service-remote-state-backend-us-east-2"
kms_key_id     = "arn:aws:kms:us-east-2:1234567890AB:key/12345678-90AB-CDEF-GHIJ-KLMNOPQRSTYWXYZ"
```

Create an state.tf file in the Terraform root directory with the following configuration:

```hcl
terraform {
  backend "s3" {
    acl     = "bucket-owner-full-control"
    encrypt = true
    region  = "us-east-2"
  }
}
```

## 5. Initialize the Terraform backend to move the state from local to S3:

```bash
terraform init -backend-config=./init-tfvars/dev.tfvars
```

Answer "yes" to the following prompt:

```
Initializing the backend...
Do you want to copy existing state to the new backend?
  Pre-existing state was found while migrating the previous "local" backend to the
  newly configured "s3" backend. No existing state was found in the newly
  configured "s3" backend. Do you want to copy this state to the new "s3"
  backend? Enter "yes" to copy and "no" to start with an empty state.

  Enter a value: 
```

---

## Resources

| Name | Type |
|------|------|
| [aws_dynamodb_table.remote_state_backend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_iam_policy.account_state_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.account_state_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.account_state_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_alias.remote_state_backend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_alias.specific_state_backend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.remote_state_backend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key.specific_remote_state_backend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_bucket.remote_state_backend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_logging.remote_state_backend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_policy.remote_state_backend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.remote_state_backend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.remote_state_backend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_arns"></a> [account\_arns](#input\_account\_arns) | Arns for accounts / roles in accounts which are given a role they are able to assume to access their state. | `list(string)` | `[]` | no |
| <a name="input_aws_s3_bucket_server_side_encryption_type"></a> [aws\_s3\_bucket\_server\_side\_encryption\_type](#input\_aws\_s3\_bucket\_server\_side\_encryption\_type) | Selection of the bucket encryption type | `string` | `"SSE_KMS"` | no |
| <a name="input_block_public_acls"></a> [block\_public\_acls](#input\_block\_public\_acls) | Blocks public ACLs on the bucket. | `bool` | `true` | no |
| <a name="input_block_public_policy"></a> [block\_public\_policy](#input\_block\_public\_policy) | Whether Amazon S3 should block public bucket policies for this bucket. | `bool` | `true` | no |
| <a name="input_dynamodb_table_billing_type"></a> [dynamodb\_table\_billing\_type](#input\_dynamodb\_table\_billing\_type) | Defines whether the DynamoDB table used for state locking and consistency checking should use on-demand or provisioned capacity mode. | `string` | `"PAY_PER_REQUEST"` | no |
| <a name="input_dynamodb_table_read_capacity"></a> [dynamodb\_table\_read\_capacity](#input\_dynamodb\_table\_read\_capacity) | Defines the number of read units for the state locking and consistency table. If the dynamodb\_table\_billing\_type is PROVISIONED, this field is required. | `number` | `0` | no |
| <a name="input_dynamodb_table_write_capacity"></a> [dynamodb\_table\_write\_capacity](#input\_dynamodb\_table\_write\_capacity) | Defines the number of write units for the state locking and consistency table. If the dynamodb\_table\_billing\_type is PROVISIONED, this field is required. | `number` | `0` | no |
| <a name="input_global_account_arns"></a> [global\_account\_arns](#input\_global\_account\_arns) | Arns for a account(s) / roles in account(s) that would be allowed access to all account states, for instance a global users account. Restrictions of which of that accounts users were able to access a given state would need to be further restricted inside of the global account(s) themselves. | `list(string)` | `[]` | no |
| <a name="input_ignore_public_acls"></a> [ignore\_public\_acls](#input\_ignore\_public\_acls) | Whether Amazon S3 should ignore public ACLs for this bucket. Causes Amazon S3 to ignore public ACLs on this bucket and any objects that it contains. | `bool` | `true` | no |
| <a name="input_input_tags"></a> [input\_tags](#input\_input\_tags) | Map of tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_log_bucket_id"></a> [log\_bucket\_id](#input\_log\_bucket\_id) | ID of logging bucket to be targeted for S3 bucket logs | `string` | n/a | yes |
| <a name="input_log_bucket_target_object_key_format"></a> [log\_bucket\_target\_object\_key\_format](#input\_log\_bucket\_target\_object\_key\_format) | Map containing logging bucket target object key format configuration. | `any` | `{}` | no |
| <a name="input_log_bucket_target_prefix"></a> [log\_bucket\_target\_prefix](#input\_log\_bucket\_target\_prefix) | The prefix for all log object keys. Define this varible to override the default. | `string` | `""` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | String to use as prefix on object names | `string` | n/a | yes |
| <a name="input_name_suffix"></a> [name\_suffix](#input\_name\_suffix) | String to append to object names. This is optional, so start with dash if using | `string` | `""` | no |
| <a name="input_restrict_public_buckets"></a> [restrict\_public\_buckets](#input\_restrict\_public\_buckets) | Whether Amazon S3 should restrict public bucket policies for this bucket. Enabling this setting does not affect the previously stored bucket policy, except that public and cross-account access within the public bucket policy, including non-public delegation to specific accounts, is blocked. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket"></a> [bucket](#output\_bucket) | bucket friendly name |
| <a name="output_dynamodb_table"></a> [dynamodb\_table](#output\_dynamodb\_table) | dynamodb friendly name |
| <a name="output_iam_role_arns"></a> [iam\_role\_arns](#output\_iam\_role\_arns) | arns for each IAM role that can be assumend for the corresponding account's terraform state |
| <a name="output_kms_default_key_alias_arn"></a> [kms\_default\_key\_alias\_arn](#output\_kms\_default\_key\_alias\_arn) | kms key arn that is created by default. Use this when just using this for a state bucket and not from other accounts. |
| <a name="output_kms_default_key_arn"></a> [kms\_default\_key\_arn](#output\_kms\_default\_key\_arn) | kms key alias arn that is created by default. Use this when just using this for a state bucket and not from other accounts. |
| <a name="output_kms_key_alias_arns"></a> [kms\_key\_alias\_arns](#output\_kms\_key\_alias\_arns) | kms key alias arns for each specific account |
| <a name="output_kms_key_arns"></a> [kms\_key\_arns](#output\_kms\_key\_arns) | kms key arns for each specific account |

---

<span style="color:red">Note:</span> Manual changes to the README will be overwritten when the documentation is updated. To update the documentation, run `terraform-docs -c .config/.terraform-docs.yml .`
<!-- END_TF_DOCS -->
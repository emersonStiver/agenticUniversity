variable "deploy_role" {
  description = "The name of the IAM role that the Pipeline in the shared account will assume to deploy infrastructure"
  type = string
  default = "TerraformDeployRole"
}
variable "shared_account_id" {
  type = string
  description = "The account id for the shared account where the pipeline is running"
}
variable "roles_path" {
  type = string
  description = "the path to save the roles related to bootstrap"
  default = "bootstrap"
}

variable "bucket_name" {
  type = string
  description = "The bucket name"
  default = "terraform"
}

variable "account_id" {
  type = string
  description = "The account id where the module resources will be created"
}

variable "bucket_kms_key_arn" {
  type = string
  description = "Custom kms key used to encrypt and decrypt objects on s3"
  default = null
}

variable "bucket_lifecycle_enabled" {
  type = bool
  description = "whether to activate the lifecycle configuration on the bucket or not"
  default = true
}

variable "bucket_versioning_enabled" {
  type = bool
  description = "whether to activate the versioning on the bucket"
  default = true
}
locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals

  environment  = local.env_vars.environment
  account_id   = local.account_vars.account_id
  account_name = local.account_vars.account_name
  aws_region   = local.region_vars.aws_region

}

remote_state {
  backend = "s3"
  generate = {
    path = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket = "tfstate-bucket-account-${var.account_id}"
    key = "${path_relative_to_include()}/terraform.tfstate"
    region = "us-east-1"
    profile = "dev"
    encrypt = true
    use_lockfile = true
  }
}

generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
    provider "aws" {
     region = "${local.aws_region}"
     profile = "dev"
    }
  EOF
}
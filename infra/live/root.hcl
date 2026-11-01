locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals
}

remote_state {
  backend = "s3"
  generate = {
    path = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket = "tfstate-bucket-account-${local.account_vars.account_id}"
    key = "${path_relative_to_include()}/terraform.tfstate"
    region = "${local.region_vars.aws_region}"
    profile = "${local.env_vars.environment}"
    encrypt = true
    use_lockfile = true
    disable_bucket_update = true
  }
}

generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
    provider "aws" {
     region = "${local.region_vars.aws_region}"
     profile = "${local.env_vars.environment}"
    }
  EOF
}
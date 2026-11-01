include {
    path = "${find_in_parent_folders("root.hcl")}"
}

locals {
    account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
    env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
}

terraform {
    source = "${dirname(find_in_parent_folders("root.hcl"))}/../modules//bootstrap"
}

# remote_state {
#     backend = "local"
#     generate = {
#         path = "backend.tf"
#         if_exists = "overwrite_terragrunt"
#     }
#     config ={
#         path = "${get_terragrunt_dir()}/terraform.tfstate"
#     }
# }

# generate "provider" {
#     path = "provider.tf"
#     if_exists = "overwrite_terragrunt"
#     contents = <<EOF
#         provider "aws" {
#             region = "us-east-1"
#             profile = "shared"
#         }
#     EOF
# }

inputs = {
    deployment_account_id = local.env_vars.deployment_account_id
    account_id = local.account_vars.account_id
}
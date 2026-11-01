include {
    path = "${find_in_parent_folders("root.hcl")}"
}

locals {
    env_args = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
    account_args = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}

terraform {
    source = "${dirname(find_in_parent_folders("root.hcl"))}/../modules//bootstrap"
}

#This block is temporary to prevent terragrunt.hcl to inject the remote_state block
#Normally, all main.tf files or terragrunt.hcl as wrappers must have a backend block 
#to specify where to store the state of the STACK UNIT. Normally when we use terraform 
#we just create the resources in a .tf file and run terraform apply, but under the hood
#a local type backend block is added.

#We will remove this and make the stack unit point to the bucket created to migrate the local state
# remote_state {
#     backend = "local"
#     generate = {
#         path = "backend.tf"
#         if_exists = "overwrite_terragrunt"
#     }
#     config = {
#         path = "${get_terragrunt_dir()}/terraform.tfstate"
#     }
# }
# #If we don't include this one, and if the include keyword is used, then terragrunt will inject the generate provider block from the root.hcl
# #But since we have this one, we won't inject anything from root.hcl
# generate "provider" {
#     path = "provider.tf"
#     if_exists = "overwrite_terragrunt"
#     contents = <<EOF
#         provider "aws" {
#             region = "us-east-1"
#             profile = "dev"
#         }
#     EOF
# } 


inputs = {
    deployment_account_id = local.env_args.deployment_account_id
    account_id = local.account_args.account_id
}
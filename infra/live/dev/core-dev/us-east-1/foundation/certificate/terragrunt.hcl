include "root" {
    path = find_in_parent_folders("root.hcl")
}

terraform {
    source = "${dirname(find_in_parent_folders("root.hcl"))}/../modules//certificate"
}

locals {
    account_vars =  read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
    env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
}

inputs = {
  domain_name   = local.account_vars.subdomain_name
  tags = {
    "Environment" = local.env_vars.environment
    "Account"     = local.account_vars.account_name
  }
}
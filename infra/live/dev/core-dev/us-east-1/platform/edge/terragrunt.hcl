include "root" {
    path = find_in_parent_folders("root.hcl")
}

dependency "certificate" {
    config_path = "${dirname(find_in_parent_folders("region.hcl"))}/foundation/certificate"
}

locals {
    account_vars =  read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
    env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
    region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals
}

terraform {
    source = "${dirname(find_in_parent_folders("root.hcl"))}/../modules//edge"
}

inputs = {
   certificate_arn  = dependency.certificate.outputs.certificate_arn
   custom_tags = {
    "Environment" = local.env_vars.environment
    "Account" = local.account_vars.account_name
    "Region" = local.region_vars.aws_region
   }
}
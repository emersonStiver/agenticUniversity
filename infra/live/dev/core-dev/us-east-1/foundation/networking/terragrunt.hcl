# live/dev/core-dev/us-east-1/foundation/terragrunt.hcl

include "root" { 
  path = find_in_parent_folders("root.hcl") 
  #expose = true only to have access to the root variables in the child terragrunt files. 
}

locals {
  env    = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
  region = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals
}

terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/../modules//vpc-module"
}

inputs = {
  cidr_block       = "10.0.0.0/16"
}
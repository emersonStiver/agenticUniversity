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
  source = "${dirname(find_in_parent_folders("root.hcl"))}/../modules//networking"
}

inputs = {
  name = "dev-networking"
  azs = ["us-east-1a", "us-east-1b", "us-east-1c"]
  nat_mode = "single"
  tiers = [
    {
      name = "private-app", zone_newbits = 2, nat = true
    },
    {
      name = "public-app", zone_newbits = 4, public = true
    },
    {
      name = "private-db", zone_newbits = 4
    },
    {
      name = "spare", zone_newbits = 4, create = false
    },
    {
      name = "admin", zone_newbits = 5, nat = true
    }
  ]
}
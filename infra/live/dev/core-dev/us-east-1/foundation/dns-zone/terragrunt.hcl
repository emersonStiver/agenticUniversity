include "root" {
    path = find_in_parent_folders("root.hcl") #-> we will inject the code defined in root.hcl
}

terraform {
    source = "${dirname(find_in_parent_folders("root.hcl"))}/../modules//dns-zone"
}

locals {
    account_vars =  read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}

inputs = {
   domain_name  =  local.account_vars.subdomain_name
}



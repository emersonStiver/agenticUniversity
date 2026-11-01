include {
    path = "${find_in_parent_folders(root.hcl)}"
}

terraform {
    source = "${dirname(find_in_parent_folders(root.hcl))}/../modules//dns-record"
}

dependency "dev_zone" {
    config_path = "${dirname(find_in_parent_folders("root.hcl"))}/dev/core-dev/us-east-1/foundation/dns-zone"
}

# dependency "prod_zone" {
#     config_path = "${dirname(find_in_parent_folders("root.hcl"))}/prod/core-prod/us-east-1/foundation/dns-zone"
# }

locals {
    account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}

inputs = {
    parent_zone_name = local.account_vars.domain_name
    records = {
        dev = sort(dependency.dev_zone.outputs.name_servers)
        #prod = sort(dependency.prod_zone.outputs.name_servers)
    }
}
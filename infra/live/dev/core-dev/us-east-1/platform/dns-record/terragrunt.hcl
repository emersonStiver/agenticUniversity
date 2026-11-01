include "root" {
    path = find_in_parent_folders("root.hcl")
}

terraform {
    source = "${dirname(find_in_parent_folders("root.hcl"))}/../modules//dns-record"
}

dependency "cloudfront_entry" {
    config_path = "../edge"
}


inputs = {
  type = "ALIAS"
  ttl = 300  
  dns_records = {
    "api" = {
        type = "A"
        name = "api.dev.emerson.link"
        alias = {
            zone_id = "Z2FDTNDATAQYW2"
            name = dependency.cloudfront_entry.outputs.cloudfront_distribution_name
        }
    }
    "app" = {
        type = "A"
        name = "app.dev.emerson.link"
        alias = {
            zone_id = "Z2FDTNDATAQYW2"
            name = dependency.cloudfront_entry.outputs.cloudfront_distribution_name
        }
    }
  }
}
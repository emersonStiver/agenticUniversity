provider "aws" {
    region = var.bucket-region
    allowed_account_ids = [ local.allowed_accounts ]
    default_tags {
      tags = local.default_tags
    }
}
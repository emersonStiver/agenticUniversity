locals {
  account_id = data.aws_caller_identity.current.account_id
  allowed_accounts = "123123123"
  region = data.aws_region.current.region
  default_tags = {
    ManagedBy = "terraform"
    Project = "agentic-university"
    Environment = "shared"
  }
}
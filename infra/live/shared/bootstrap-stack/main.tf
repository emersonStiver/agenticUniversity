module "s3-tfstate-bucket-module" {
  source = "../../../modules/s3-tfstate-bucket-module"
  bucket-name = "${local.default_tags.Project}-tfstate-bucket-${local.default_tags.Environment}-${local.account_id}"
  bucket-region = var.bucket-region
}

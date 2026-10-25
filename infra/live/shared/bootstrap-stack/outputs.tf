output "bucket-name" {
  type = string
  value = module.s3-tfstate-bucket-module.bucket-name 
  description = "The name of the bucket that stores the state in the account" 
}

output "bucket-id" {
  type = string
  value = module.s3-tfstate-bucket-module.bucket-id
  description = "The ID of the bucket that stores the state in the account"
}

output "bucket-arn" {
    type = string
    value = module.s3-tfstate-bucket-module.bucket-arn
    description = "The ARN for the bucket that stores the state in the account"
}
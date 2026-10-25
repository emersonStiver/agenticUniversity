output "bucket-name" {
  value = aws_s3_bucket.this.bucket
  description = "The tfstate bucket name"
}

output "bucket-arn" {
  value = aws_s3_bucket.this.arn
  description = "The tfstate bucket arn"
}
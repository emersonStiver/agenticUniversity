resource "aws_s3_bucket" "this" {
  bucket = "tfstate-bucket-account-${var.account_id}"
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.bucket
  block_public_acls       = true
  block_public_policy    = true
  ignore_public_acls     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.bucket
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.bucket_kms_key_arn == null ? "AES256" : "aws:kms"
      kms_master_key_id = var.bucket_kms_key_arn
    }
    bucket_key_enabled = var.bucket_kms_key_arn != null
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count = var.bucket_lifecycle_enabled ? 1 : 0
  bucket = aws_s3_bucket.this.bucket
  rule {
    id = "DisposingNonConcurrentVersions"
    status = "Enabled"
    noncurrent_version_transition {
      noncurrent_days = 1
      storage_class = "GLACIER"
    }
    noncurrent_version_expiration {
      noncurrent_days = 10
    }
    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.bucket
  versioning_configuration {
  status = var.bucket_versioning_enabled ? "Enabled" : "Suspended"
  }
}
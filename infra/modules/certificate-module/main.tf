resource "aws_acm_certificate" "this" {
  key_algorithm = "EC_prime256v1"
  domain_name = var.domain_name
  subject_alternative_names = [ "*.${var.domain_name}" ]
  validation_method = "DNS"
  options {
    export = "DISABLED"
  }
  tags = var.tags
}

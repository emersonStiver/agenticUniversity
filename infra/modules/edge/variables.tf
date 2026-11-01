variable "domain_name" {
  type = set(string)
  description = "When user asks Host: 'app.example.com' by hitting the cloudfront ip, this will let CF know what distribution corresponds to this domain name"
}

variable "custom_tags" {
  type = map(string)
  description = "A map of tags to apply to the resource"
  default = {}
}

variable "certificate_arn" {
  type = string
  description = "certificate for the cloudfront distribution"
}

variable "bucket_domain_name" {
  type = string
  description = "The endpoint for the s3 bucket"
}
variable "alb_dns_name" {
  type = string
}

variable "alb_arn" {
  type = string
}
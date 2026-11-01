variable "domain_name" {
  type = "string"
  description = "domain name for the certificate"
}

variable "tags" {
  type = map(string)
  description = "common tags"
}
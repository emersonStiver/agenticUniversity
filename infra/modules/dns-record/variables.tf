variable "type" {
  type = string
  description = "The type of DNS Record we will create"
}


variable "dns_records" {
  type = map(object({
    type = string
    name = string

    alias = optional(object({
      name = string
      zone_id = string
    }))

    ttl = optional(number)
    records = optional(list(string))

  }))
  description = "A map of subdomains to their respective delegation nameservers"
  default = {}
  validation {
    condition = alltrue([for r in values(var.dns_records) : (r.alias == null) != (r.records == null)])
    error_message = "Either alias or records have to be set "
  }
}

variable "parent_zone_name" {
  type = string
  description = "Existing public zone to add the NS records to, e.g. emerson.link"
}
variable "name" {
  type = string
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid CIDR block."
  }
}

variable "azs" {
  type        = list(string)
  description = "Explicit AZ list, e.g. [\"us-east-1a\", \"us-east-1b\", \"us-east-1c\"]"

  validation {
    condition     = length(var.azs) >= 2 && length(var.azs) <= 4
    error_message = "Use between 2 and 4 AZs."
  }
}

variable "tiers" {
  description = "Ordered list. The order decides address allocation, so only append new tiers at the end."
  type = list(object({
    name         = string
    zone_newbits = number                  # size of this tier's zone inside the VPC
    public       = optional(bool, false)   # route to the internet gateway
    nat          = optional(bool, false)   # outbound internet through NAT
    create       = optional(bool, true)    # false = reserve the space, create nothing
  }))
}

variable "nat_mode" {
  type    = string
  default = "single"

  validation {
    condition     = contains(["none", "single", "per_az", "regional"], var.nat_mode)
    error_message = "nat_mode must be none, single, per_az, or regional."
  }
}
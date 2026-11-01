locals {
    # Assigns each tier its own zone of addresses inside the VPC.
    #
    # Why cidrsubnets and not cidrsubnet:
    #   cidrsubnet(prefix, newbits, netnum) cuts the network into 2^newbits equal
    #   slices and returns the one at position netnum. Each call is independent
    #   and knows nothing about the others, so with tiers of different sizes you'd
    #   have to calculate every netnum by hand to avoid overlaps.
    #
    #   cidrsubnets(prefix, newbits...) takes one newbits per tier and allocates
    #   the blocks one after another, in list order, with no overlaps. Alignment
    #   can still leave gaps, which is why the tier list goes largest first.
    #
    # zipmap then pairs each tier name with its block.
    #
    # Output example (VPC 10.0.0.0/16):
    #   {
    #     "public_sub"      = "10.0.0.0/20"    # newbits 4
    #     "private_app_sub" = "10.0.16.0/24"   # newbits 8
    #     ...
    #   }
    network_layout = zipmap(
      [for t in var.tiers : t.name],
      cidrsubnets(var.vpc_cidr, [for t in var.tiers : t.zone_newbits]...)
    )
    


  # Each tier (public-app, private-app, ...) gets its own zone of addresses.
  # az_newbits splits every zone into 2^2 = 4 equal slots, one subnet per AZ.
  #
  # Example: zone 10.0.64.0/20 + 2 bits = four /22 subnets
  #   /20 mask: 11111111.11111111.11110000.00000000
  #   /22 mask: 11111111.11111111.11111100.00000000
  #                                   ^^ the 2 added bits pick the slot:
  #   00 = 10.0.64.0/22   01 = 10.0.68.0/22   10 = 10.0.72.0/22   11 = 10.0.76.0/22
  #
  # We use 3 AZs, so 3 slots are used and 1 stays free for a future 4th AZ.
  # Keep this value fixed: changing it resizes every subnet and forces
  # Terraform to destroy and recreate them.
  az_newbits = 2

  #tenemos x cantidad de tiers (pub_sub, pri_app_sub, pri_db_sub, admin_sub, spare_sub)
                                #pub_sub-az1, pub_sub-az2, pub_sub-az3
                                #pri_app_sub-az1, pri_app_sub-az2, pri_app_sub-az3
  subnet_list = flatten([
    for t in var.tiers : [
      for i, az in var.azs : {
        key    = "${t.name}-${az}"
        tier   = t.name
        az     = az
        cidr   = cidrsubnet(local.network_layout[t.name], local.az_newbits, i)
        public = t.public
        nat    = t.nat
      }
    ] if t.create
  ])
  subnets = {for s in subnet_list : s.key => s}
  public_tier = one([for t in var.tiers : t.name if t.public])
}
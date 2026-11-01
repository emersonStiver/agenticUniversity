output "subnet_ids" {
  value = {
    for t in var.tiers : t.name => [
      for k, s in aws_subnet.this : s.id if local.subnets[k].tier == t.name
    ] if t.create
  }
}


data "aws_route53_zone" "this" {
   name = var.parent_zone_name
   private_zone = false
}

resource "aws_route53_record" "this" {
  for_each = var.dns_records
  zone_id = data.aws_route53_zone.this.id
  type = each.value.type
  name = each.value.name

  ttl = each.value.ttl  #if null, then they won't be included
  records = each.value.records # if null, then, they won't be included

  dynamic "alias" { #the only way to include a conditional  block
    for_each = each.value.alias == null? [] : [each.vale.alias]
    content {
      name = alias.value.name
      zone_id = alias.value.zone_id
      evaluate_target_health = true
    }
  }
}
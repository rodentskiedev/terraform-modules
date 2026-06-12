resource "aws_route53_zone" "this" {
  for_each = var.hosted_zones

  name    = each.value.name
  comment = each.value.comment
  tags    = each.value.tags
}

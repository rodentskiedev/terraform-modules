resource "aws_network_acl_rule" "this" {
  for_each = var.network_acl_rules

  network_acl_id = each.value.network_acl_id
  rule_number    = each.value.rule_number
  egress         = each.value.egress
  protocol       = each.value.protocol
  rule_action    = each.value.rule_action
  cidr_block     = each.value.cidr_block
  from_port      = each.value.from_port
  to_port        = each.value.to_port
  icmp_type      = each.value.icmp_type
  icmp_code      = each.value.icmp_code
}

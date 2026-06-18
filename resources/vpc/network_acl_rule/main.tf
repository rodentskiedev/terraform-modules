locals {
  public_rules = {
    for key, rule in var.public_rules : "public-${key}" => {
      network_acl_id = var.public_network_acl_id
      rule_number    = rule.rule_number
      egress         = rule.egress
      protocol       = rule.protocol
      rule_action    = rule.rule_action
      cidr_block     = rule.cidr_block
      from_port      = rule.from_port
      to_port        = rule.to_port
      icmp_type      = rule.icmp_type
      icmp_code      = rule.icmp_code
    }
  }
  private_rules = {
    for key, rule in var.private_rules : "private-${key}" => {
      network_acl_id = var.private_network_acl_id
      rule_number    = rule.rule_number
      egress         = rule.egress
      protocol       = rule.protocol
      rule_action    = rule.rule_action
      cidr_block     = rule.cidr_block
      from_port      = rule.from_port
      to_port        = rule.to_port
      icmp_type      = rule.icmp_type
      icmp_code      = rule.icmp_code
    }
  }
}

resource "aws_network_acl_rule" "this" {
  for_each = merge(local.public_rules, local.private_rules)

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

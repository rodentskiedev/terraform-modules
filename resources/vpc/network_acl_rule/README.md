# resources/vpc/network_acl_rule

Creates individual Network ACL rules. NACLs are stateless, so both ingress and egress rules must be explicitly defined. Rule numbers determine evaluation order — lower numbers are evaluated first. Use `protocol = "-1"` for all traffic; when doing so, omit `from_port` and `to_port` (AWS ignores them and the provider will treat null as 0).

## Sample Terragrunt Usage

```hcl
terraform {
  source = "git::https://github.com/<org>/terraform-modules.git//resources/vpc/network_acl_rule?ref=v0.0.x"
}

dependency "network_acl" {
  config_path = "../network_acl"
}

inputs = {
  network_acl_rules = {
    public-ingress-all = {
      network_acl_id = dependency.network_acl.outputs.network_acls["public"].id
      rule_number    = 100
      egress         = false
      protocol       = "-1"
      rule_action    = "allow"
      cidr_block     = "0.0.0.0/0"
    }
    public-egress-all = {
      network_acl_id = dependency.network_acl.outputs.network_acls["public"].id
      rule_number    = 100
      egress         = true
      protocol       = "-1"
      rule_action    = "allow"
      cidr_block     = "0.0.0.0/0"
    }
    private-ingress-all = {
      network_acl_id = dependency.network_acl.outputs.network_acls["private"].id
      rule_number    = 100
      egress         = false
      protocol       = "-1"
      rule_action    = "allow"
      cidr_block     = "0.0.0.0/0"
    }
    private-egress-all = {
      network_acl_id = dependency.network_acl.outputs.network_acls["private"].id
      rule_number    = 100
      egress         = true
      protocol       = "-1"
      rule_action    = "allow"
      cidr_block     = "0.0.0.0/0"
    }
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| region | AWS region to use for the provider. | `string` | `"ap-southeast-1"` | no |
| network_acl_rules | Map of Network ACL rules to create. The key is used as a unique identifier. | `map(object({...}))` | n/a | yes |
| network_acl_rules.network_acl_id | ID of the Network ACL to attach this rule to. | `string` | n/a | yes |
| network_acl_rules.rule_number | Rule evaluation order. Lower numbers are evaluated first. | `number` | n/a | yes |
| network_acl_rules.egress | Whether the rule applies to egress traffic (`true`) or ingress (`false`). | `bool` | n/a | yes |
| network_acl_rules.protocol | Protocol number or name. Use `"-1"` for all traffic, `"6"` for TCP, `"17"` for UDP. | `string` | n/a | yes |
| network_acl_rules.rule_action | Whether to `"allow"` or `"deny"` matching traffic. | `string` | n/a | yes |
| network_acl_rules.cidr_block | CIDR block to match. | `string` | `null` | no |
| network_acl_rules.from_port | Start of port range. Required for TCP/UDP. | `number` | `null` | no |
| network_acl_rules.to_port | End of port range. Required for TCP/UDP. | `number` | `null` | no |
| network_acl_rules.icmp_type | ICMP type. Required when protocol is ICMP. | `number` | `null` | no |
| network_acl_rules.icmp_code | ICMP code. Required when protocol is ICMP. | `number` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| network_acl_rules | Map of rule key to attributes (id, network_acl_id, rule_number, egress). |

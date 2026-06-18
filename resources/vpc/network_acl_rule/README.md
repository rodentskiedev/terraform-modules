# resources/vpc/network_acl_rule

Creates Network ACL rules for public and private NACLs. Rules are defined separately per NACL type — no need to repeat the NACL ID on every rule. NACLs are stateless, so both ingress and egress must be explicitly defined. Use `protocol = "-1"` for all traffic; omit `from_port` and `to_port` when doing so.

## Sample Terragrunt Usage

```hcl
terraform {
  source = "git::https://github.com/<org>/terraform-modules.git//resources/vpc/network_acl_rule?ref=v0.0.x"
}

dependency "network_acl" {
  config_path = "../network_acl"
}

inputs = {
  public_network_acl_id  = dependency.network_acl.outputs.network_acls["public"].id
  private_network_acl_id = dependency.network_acl.outputs.network_acls["private"].id

  public_rules = {
    ingress-all = { rule_number = 100, egress = false, protocol = "-1", rule_action = "allow", cidr_block = "0.0.0.0/0" }
    egress-all  = { rule_number = 100, egress = true,  protocol = "-1", rule_action = "allow", cidr_block = "0.0.0.0/0" }
  }

  private_rules = {
    ingress-all = { rule_number = 100, egress = false, protocol = "-1", rule_action = "allow", cidr_block = "0.0.0.0/0" }
    egress-all  = { rule_number = 100, egress = true,  protocol = "-1", rule_action = "allow", cidr_block = "0.0.0.0/0" }
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| region | AWS region to use for the provider. | `string` | `"ap-southeast-1"` | no |
| public_network_acl_id | ID of the public Network ACL to attach rules to. | `string` | n/a | yes |
| private_network_acl_id | ID of the private Network ACL to attach rules to. | `string` | n/a | yes |
| public_rules | Map of rules for the public NACL. The key is used as a unique identifier. | `map(object({...}))` | `{}` | no |
| private_rules | Map of rules for the private NACL. The key is used as a unique identifier. | `map(object({...}))` | `{}` | no |
| public_rules.rule_number | Rule evaluation order. Lower numbers are evaluated first. | `number` | n/a | yes |
| public_rules.egress | `true` for egress, `false` for ingress. | `bool` | n/a | yes |
| public_rules.protocol | Protocol. Use `"-1"` for all traffic, `"6"` for TCP, `"17"` for UDP. | `string` | n/a | yes |
| public_rules.rule_action | `"allow"` or `"deny"`. | `string` | n/a | yes |
| public_rules.cidr_block | CIDR block to match. | `string` | `null` | no |
| public_rules.from_port | Start of port range. Required for TCP/UDP. | `number` | `null` | no |
| public_rules.to_port | End of port range. Required for TCP/UDP. | `number` | `null` | no |
| public_rules.icmp_type | ICMP type. Required when protocol is ICMP. | `number` | `null` | no |
| public_rules.icmp_code | ICMP code. Required when protocol is ICMP. | `number` | `null` | no |

> `private_rules` accepts the same fields as `public_rules`.

## Outputs

| Name | Description |
|------|-------------|
| network_acl_rules | Map of rule key to attributes (id, network_acl_id, rule_number, egress). |

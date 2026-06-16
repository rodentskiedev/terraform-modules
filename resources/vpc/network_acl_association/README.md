# resources/vpc/network_acl_association

Associates subnets with Network ACLs. Each subnet can only be associated with one NACL at a time — associating a new NACL replaces the existing one. Create one entry per subnet.

## Sample Terragrunt Usage

```hcl
terraform {
  source = "git::https://github.com/<org>/terraform-modules.git//resources/vpc/network_acl_association?ref=v0.0.x"
}

dependency "subnet" {
  config_path = "../subnet"
}

dependency "network_acl" {
  config_path = "../network_acl"
}

inputs = {
  network_acl_associations = {
    public-az-a = {
      network_acl_id = dependency.network_acl.outputs.network_acls["public"].id
      subnet_id      = dependency.subnet.outputs.subnets["public-az-a"].id
    }
    public-az-b = {
      network_acl_id = dependency.network_acl.outputs.network_acls["public"].id
      subnet_id      = dependency.subnet.outputs.subnets["public-az-b"].id
    }
    private-az-a = {
      network_acl_id = dependency.network_acl.outputs.network_acls["private"].id
      subnet_id      = dependency.subnet.outputs.subnets["private-az-a"].id
    }
    private-az-b = {
      network_acl_id = dependency.network_acl.outputs.network_acls["private"].id
      subnet_id      = dependency.subnet.outputs.subnets["private-az-b"].id
    }
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| region | AWS region to use for the provider. | `string` | `"ap-southeast-1"` | no |
| network_acl_associations | Map of Network ACL associations to create. The key is used as a unique identifier. | `map(object({...}))` | n/a | yes |
| network_acl_associations.network_acl_id | ID of the Network ACL to associate. | `string` | n/a | yes |
| network_acl_associations.subnet_id | ID of the subnet to associate with the Network ACL. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| network_acl_associations | Map of association key to attributes (id, network_acl_id, subnet_id). |

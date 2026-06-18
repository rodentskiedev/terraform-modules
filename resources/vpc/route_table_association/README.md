# resources/vpc/route_table_association

Associates subnets with route tables. Without this, subnets use the VPC's main (default) route table. Create one association per subnet — one entry per public subnet pointing to the public route table, and one per private subnet pointing to its AZ-local private route table.

## Sample Terragrunt Usage

```hcl
terraform {
  source = "git::https://github.com/<org>/terraform-modules.git//resources/vpc/route_table_association?ref=v0.0.x"
}

dependency "subnet" {
  config_path = "../subnet"
}

dependency "route_table" {
  config_path = "../route_table"
}

inputs = {
  route_table_associations = {
    public-az-a = {
      subnet_id      = dependency.subnet.outputs.public_subnets["ap-southeast-1a"].id
      route_table_id = dependency.route_table.outputs.route_tables["public"].id
    }
    public-az-b = {
      subnet_id      = dependency.subnet.outputs.public_subnets["ap-southeast-1b"].id
      route_table_id = dependency.route_table.outputs.route_tables["public"].id
    }
    private-az-a = {
      subnet_id      = dependency.subnet.outputs.private_subnets["ap-southeast-1a"].id
      route_table_id = dependency.route_table.outputs.route_tables["private"].id
    }
    private-az-b = {
      subnet_id      = dependency.subnet.outputs.private_subnets["ap-southeast-1b"].id
      route_table_id = dependency.route_table.outputs.route_tables["private"].id
    }
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| region | AWS region to use for the provider. | `string` | `"ap-southeast-1"` | no |
| route_table_associations | Map of route table associations to create. The key is used as a unique identifier. | `map(object({...}))` | n/a | yes |
| route_table_associations.subnet_id | ID of the subnet to associate. | `string` | n/a | yes |
| route_table_associations.route_table_id | ID of the route table to associate the subnet with. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| route_table_associations | Map of association key to attributes (id, subnet_id, route_table_id). |

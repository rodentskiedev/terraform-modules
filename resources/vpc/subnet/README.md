# resources/vpc/subnet

Creates one or more AWS subnets within a VPC. Each subnet is scoped to a single availability zone. Pass one entry per AZ to spread subnets across multiple AZs. Public subnets should set `map_public_ip_on_launch = true`.

## Sample Terragrunt Usage

```hcl
terraform {
  source = "git::https://github.com/<org>/terraform-modules.git//resources/vpc/subnet?ref=v0.0.x"
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  subnets = {
    public-az-a = {
      vpc_id                  = dependency.vpc.outputs.vpcs["main"].id
      cidr_block              = "10.0.1.0/24"
      availability_zone       = "ap-southeast-1a"
      map_public_ip_on_launch = true
      tags                    = { Name = "public-az-a", Environment = "production" }
    }
    public-az-b = {
      vpc_id                  = dependency.vpc.outputs.vpcs["main"].id
      cidr_block              = "10.0.2.0/24"
      availability_zone       = "ap-southeast-1b"
      map_public_ip_on_launch = true
      tags                    = { Name = "public-az-b", Environment = "production" }
    }
    private-az-a = {
      vpc_id            = dependency.vpc.outputs.vpcs["main"].id
      cidr_block        = "10.0.10.0/24"
      availability_zone = "ap-southeast-1a"
      tags              = { Name = "private-az-a", Environment = "production" }
    }
    private-az-b = {
      vpc_id            = dependency.vpc.outputs.vpcs["main"].id
      cidr_block        = "10.0.11.0/24"
      availability_zone = "ap-southeast-1b"
      tags              = { Name = "private-az-b", Environment = "production" }
    }
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| region | AWS region to use for the provider. | `string` | `"ap-southeast-1"` | no |
| subnets | Map of subnets to create. The key is used as a unique identifier. | `map(object({...}))` | n/a | yes |
| subnets.vpc_id | ID of the VPC to create the subnet in. | `string` | n/a | yes |
| subnets.cidr_block | CIDR block for the subnet. | `string` | n/a | yes |
| subnets.availability_zone | Availability zone for the subnet. | `string` | n/a | yes |
| subnets.map_public_ip_on_launch | Whether to assign a public IP to instances launched in this subnet. | `bool` | `false` | no |
| subnets.tags | Tags to apply to the subnet. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| subnets | Map of subnet key to subnet attributes (id, cidr_block, availability_zone, vpc_id). |

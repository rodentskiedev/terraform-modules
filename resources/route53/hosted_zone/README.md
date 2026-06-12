# resources/route53/hosted_zone

Creates one or more Route53 public hosted zones. The `name_servers` output can be used to delegate the zone from a parent domain or a registrar.

## Sample Terragrunt Usage

```hcl
terraform {
  source = "git::https://github.com/<org>/terraform-modules.git//resources/route53/hosted_zone?ref=v1.0.0"
}

include "root" {
  path = find_in_parent_folders()
}

inputs = {
  hosted_zones = {
    prod = {
      name    = "yourdomain.com"
      comment = "Production hosted zone"
      tags    = { Environment = "prod" }
    }
    staging = {
      name = "staging.yourdomain.com"
      tags = { Environment = "staging" }
    }
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `region` | AWS region to use for the provider | `string` | `"ap-southeast-1"` | no |
| `hosted_zones` | Map of hosted zones to create | `map(object)` | — | yes |
| `hosted_zones[*].name` | Domain name for the hosted zone | `string` | — | yes |
| `hosted_zones[*].comment` | Comment for the hosted zone | `string` | `null` | no |
| `hosted_zones[*].tags` | Tags to apply to the hosted zone | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `hosted_zones` | Map of hosted zone key to `{ id, arn, name, name_servers }` |

# resources/lb/listener_rule

Creates one or more ALB listener rules that forward traffic to a target group based on path or host conditions. The listener ARN and target group ARN come from Terragrunt `dependency` blocks.

## Sample Terragrunt Usage

```hcl
terraform {
  source = "git::https://github.com/<org>/terraform-modules.git//resources/lb/listener_rule?ref=v0.0.1"
}

include "root" {
  path = find_in_parent_folders()
}

dependency "listener" {
  config_path = "../listener"
}

dependency "target_group" {
  config_path = "../target_group"
}

inputs = {
  project     = "myapp"
  environment = "production"

  listener_rules = {
    api = {
      listener_arn     = dependency.listener.outputs.listeners["https"].arn
      priority         = 100
      target_group_arn = dependency.target_group.outputs.target_groups["api"].arn
      conditions = [
        {
          type   = "path-pattern"
          values = ["/api/*"]
        }
      ]
    }
    web = {
      listener_arn     = dependency.listener.outputs.listeners["https"].arn
      priority         = 200
      target_group_arn = dependency.target_group.outputs.target_groups["web"].arn
      conditions = [
        {
          type   = "host-header"
          values = ["app.example.com"]
        }
      ]
    }
  }

  tags = {
    ManagedBy = "terraform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `region` | AWS region to use for the provider | `string` | `"ap-southeast-1"` | no |
| `project` | Project name, used as a prefix for resource names | `string` | — | yes |
| `environment` | Deployment environment | `string` | `"develop"` | no |
| `tags` | Tags applied to all listener rules | `map(string)` | `{}` | no |
| `listener_rules` | Map of listener rules to create (see fields below) | `map(object)` | — | yes |

### listener_rules fields

| Field | Description | Default |
|-------|-------------|---------|
| `listener_arn` | ARN of the listener to attach the rule to | required |
| `priority` | Rule evaluation order (1–50000, lower = higher priority) | required |
| `target_group_arn` | ARN of the target group to forward traffic to | required |
| `conditions` | List of conditions (see below) | required |

### conditions fields

| Field | Description |
|-------|-------------|
| `type` | `"path-pattern"` or `"host-header"` |
| `values` | List of patterns to match (supports `*` and `?` wildcards) |

## Outputs

| Name | Description |
|------|-------------|
| `listener_rules` | Map of rule key to `{ arn, priority }` |

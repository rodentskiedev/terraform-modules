# aws_sso/aws_account_assignment

Assigns groups to AWS accounts with a permission set in IAM Identity Center.

Each entry is one (account, group, permission set) combination. Obtain `instance_arn` from the `data/sso_instance` module, `group_id` from the `aws_groups` module, and `permission_set_arn` from the `aws_permission_sets` module.

## Sample Terragrunt Usage

```hcl
terraform {
  source = "git::https://github.com/<org>/terraform-modules.git//aws_sso/aws_account_assignment?ref=v1.0.0"
}

include "root" {
  path = find_in_parent_folders()
}

dependency "sso" {
  config_path = "../../data/sso_instance"
}

dependency "groups" {
  config_path = "../aws_groups"
}

dependency "permission_sets" {
  config_path = "../aws_permission_sets"
}

inputs = {
  instance_arn = dependency.sso.outputs.instance_arn

  assignments = {
    admins-prod = {
      account_id         = "111111111111"
      group_id           = dependency.groups.outputs.groups["admins"].group_id
      permission_set_arn = dependency.permission_sets.outputs.permission_sets["admin"].permission_set_arn
    }
    admins-staging = {
      account_id         = "222222222222"
      group_id           = dependency.groups.outputs.groups["admins"].group_id
      permission_set_arn = dependency.permission_sets.outputs.permission_sets["admin"].permission_set_arn
    }
    developers-prod = {
      account_id         = "111111111111"
      group_id           = dependency.groups.outputs.groups["developers"].group_id
      permission_set_arn = dependency.permission_sets.outputs.permission_sets["power-user"].permission_set_arn
    }
    read-only-prod = {
      account_id         = "111111111111"
      group_id           = dependency.groups.outputs.groups["read-only"].group_id
      permission_set_arn = dependency.permission_sets.outputs.permission_sets["read-only"].permission_set_arn
    }
  }
}
```

## Outputs

| Name | Description |
|------|-------------|
| `assignments` | Map of assignment key to `{ account_id, group_id, permission_set_arn }` |

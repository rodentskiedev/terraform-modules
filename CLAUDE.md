# CLAUDE.md

This repository contains reusable Terraform modules. Modules are not applied directly — they are consumed by a separate Terragrunt repository via `?ref=` pins.

## Repository layout

Three top-level groups organize modules by purpose:

| Group | Purpose |
|-------|---------|
| `aws_sso/` | IAM Identity Center: accounts, OUs, groups, users, permission sets, assignments |
| `data/` | Read-only data source lookups (organization, accounts, SSO instance) |
| `resources/` | AWS resource provisioning (ACM, Route53); may be nested one level (e.g., `resources/route53/hosted_zone`) |

## Module file structure

Every module contains exactly these six files — no more, no less:

| File | Role |
|------|------|
| `main.tf` | Resource or data source blocks |
| `variables.tf` | All input variables with types and descriptions |
| `outputs.tf` | All outputs callers may need |
| `provider.tf` | `provider "aws" { region = var.region }` |
| `versions.tf` | `required_version` and `required_providers` constraints |
| `README.md` | Module description, inputs table, outputs table, sample Terragrunt usage |

Do not add `locals.tf`, `data.tf`, or any other file split unless the module is large enough to justify it (it hasn't been needed yet).

## Authoring conventions

### Resource naming

Always name the primary resource or data source `this`:

```hcl
resource "aws_acm_certificate" "this" { ... }
data "aws_organizations_organization" "this" {}
```

### Map-of-objects input pattern

Every module accepts a `map(object(...))` as its primary input. This lets callers create any number of resources in one invocation. The map key is used as the `for_each` key and appears in the output.

```hcl
# variables.tf
variable "certificates" {
  description = "Map of ACM certificates to create. The key is used as a unique identifier."
  type = map(object({
    domain_name       = string
    validation_method = optional(string, "DNS")
    tags              = optional(map(string), {})
  }))
}

# main.tf
resource "aws_acm_certificate" "this" {
  for_each          = var.certificates
  domain_name       = each.value.domain_name
  validation_method = each.value.validation_method
  tags              = each.value.tags
}
```

Use `optional(type, default)` for fields that have sensible defaults. Required fields have no default.

### Region variable

Every module declares the `region` variable and uses it in `provider.tf`. Do not hardcode a region anywhere else.

```hcl
# variables.tf
variable "region" {
  description = "AWS region to use for the provider."
  type        = string
  default     = "ap-southeast-1"
}

# provider.tf
provider "aws" {
  region = var.region
}
```

### versions.tf

```hcl
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}
```

### Outputs

Mirror the input map key so callers can reference entries by the same key they supplied:

```hcl
output "certificates" {
  description = "Map of certificate key to certificate attributes."
  value = {
    for key, cert in aws_acm_certificate.this : key => {
      arn    = cert.arn
      status = cert.status
    }
  }
}
```

Only expose attributes that callers actually need. Do not output the full resource object.

### No cross-module calls

Modules never call other modules inside this repository. Cross-module data (e.g., an SSO instance ARN used by an account assignment) flows through Terragrunt `dependency` blocks in the calling repository.

## Module README format

Each module's `README.md` follows this structure:

```markdown
# <group>/<module>

One-paragraph description of what the module does and when to use it.

## Sample Terragrunt Usage

(full hcl block with dependency blocks and inputs example)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
...

## Outputs

| Name | Description |
|------|-------------|
...
```

The header matches the module's path relative to the repo root (e.g., `# resources/acm`, `# aws_sso/aws_account_assignment`).

## Versioning

A single semver git tag (`v0.0.x`) covers the whole repository. Bump on every merge that changes any module. Callers pin via `?ref=`:

```hcl
terraform {
  source = "git::https://github.com/<org>/terraform-modules.git//resources/acm?ref=v0.0.9"
}
```

## Adding a new module

1. Choose or create a group directory (`aws_sso/`, `data/`, `resources/`).
2. Create the module directory with `snake_case` naming.
3. Add all six required files.
4. Follow the map-of-objects pattern for the primary input.
5. Name the primary resource `this`.
6. Write the `README.md` using the format above.
7. Run `terraform validate` and `terraform fmt` locally before opening a PR.

## What this repo does NOT contain

- No root Terraform configurations
- No state backend configuration
- No provider authentication (credentials come from the Terragrunt caller's environment)
- No `.tfvars` files
- No Terragrunt files (`terragrunt.hcl`)

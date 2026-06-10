# terraform-modules

Reusable Terraform modules consumed via [Terragrunt](https://terragrunt.gruntwork.io/).

## Overview

This repository contains low-level Terraform modules only — no root configurations, no state backends, no provider blocks. All orchestration, environment composition, and DRY wiring is handled by a separate Terragrunt repository that references these modules as sources.

## Repository Structure

```
terraform-modules/
├── <module-name>/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── README.md
└── ...
```

Each top-level directory is an independent module. Modules are versioned via git tags and referenced from Terragrunt configurations using a `?ref=` pin:

```hcl
# In your Terragrunt repo
terraform {
  source = "git::https://github.com/<org>/terraform-modules.git//<module-name>?ref=v1.0.0"
}
```

## Conventions

- Each module is self-contained: no cross-module dependencies.
- Modules expose all tuneable behavior through `variables.tf` — no hardcoded values.
- All outputs that callers may need are declared in `outputs.tf`.
- Provider configuration is left to the caller (Terragrunt root).

## Usage

Modules are not intended to be applied directly with `terraform`. Use the companion Terragrunt repository to deploy them.

## Contributing

1. Create a new directory for the module.
2. Add `main.tf`, `variables.tf`, `outputs.tf`, and a module-level `README.md`.
3. Open a pull request — CI will run `terraform validate` and `terraform fmt -check` against all modules.
4. On merge, tag a new release following [semver](https://semver.org/).

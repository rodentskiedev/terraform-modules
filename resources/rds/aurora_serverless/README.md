# resources/rds/aurora_serverless

Creates one or more Aurora Serverless v2 clusters. Each cluster gets a DB subnet group and one or more `db.serverless` instances. The master password is managed by RDS via AWS Secrets Manager (`manage_master_user_password = true`) — no password is stored in Terraform state. The secret ARN is available in the output.

Subnet IDs and security group IDs come from Terragrunt `dependency` blocks.

## Sample Terragrunt Usage

```hcl
terraform {
  source = "git::https://github.com/<org>/terraform-modules.git//resources/rds/aurora_serverless?ref=v0.0.1"
}

include "root" {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"
}

dependency "sg" {
  config_path = "../sg"
}

inputs = {
  project     = "myapp"
  environment = "production"
  config_file = "${get_terragrunt_dir()}/config/config.yml"

  subnet_ids         = values(dependency.vpc.outputs.private_subnets)[*].id
  security_group_ids = [dependency.sg.outputs.security_groups["rds"].id]

  tags = {
    ManagedBy = "terraform"
  }
}
```

### config/config.yml

```yaml
clusters:
  main:
    engine: aurora-postgresql
    engine_version: "16.4"
    database_name: myapp
    master_username: admin
    min_capacity: 0.5
    max_capacity: 8
    instances: 1
    backup_retention_period: 7
    deletion_protection: false
    skip_final_snapshot: true
```

> Set `instances: 2` for a writer + one reader (recommended for production). Scaling from 1 → 2 adds a new instance without replacing the writer.

> Set `skip_final_snapshot: false` and `deletion_protection: true` for production clusters.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `region` | AWS region to use for the provider | `string` | `"ap-southeast-1"` | no |
| `project` | Project name, used as a prefix for resource names | `string` | — | yes |
| `environment` | Deployment environment | `string` | `"develop"` | no |
| `config_file` | Absolute path to the YAML config file | `string` | — | yes |
| `subnet_ids` | Subnet IDs for the DB subnet group (min 2, across AZs) | `list(string)` | — | yes |
| `security_group_ids` | Security group IDs to associate with the cluster | `list(string)` | — | yes |
| `tags` | Tags applied to all resources | `map(string)` | `{}` | no |

### config.yml clusters fields

| Field | Description | Default |
|-------|-------------|---------|
| `engine` | Aurora engine (`aurora-postgresql` or `aurora-mysql`) | `"aurora-postgresql"` |
| `engine_version` | Engine version (e.g. `"16.4"`) | required |
| `database_name` | Initial database name | required |
| `master_username` | Master DB username | required |
| `min_capacity` | Minimum ACU for Serverless v2 scaling (0.5–128) | `0.5` |
| `max_capacity` | Maximum ACU for Serverless v2 scaling (0.5–128) | `8` |
| `instances` | Number of cluster instances (writer + readers) | `1` |
| `backup_retention_period` | Days to retain automated backups | `7` |
| `deletion_protection` | Prevent accidental cluster deletion | `false` |
| `skip_final_snapshot` | Skip final snapshot on cluster deletion | `true` |

## Outputs

| Name | Description |
|------|-------------|
| `clusters` | Map of cluster key to `{ arn, endpoint, reader_endpoint, port, database_name, master_username, master_user_secret_arn }` |

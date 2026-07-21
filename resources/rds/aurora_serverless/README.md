# resources/rds/aurora_serverless

Creates one or more Aurora Serverless v2 clusters. Each cluster gets a DB subnet group and one or more `db.serverless` instances. Storage is always encrypted with a customer-managed KMS key (see `resources/kms`).

Credentials are never generated or managed by this module. A single Secrets Manager secret (`credentials_secret_id`) holds every cluster's master credentials as flat JSON keys — created and populated outside Terraform. Each cluster in `config_file` picks its own pair via `username_key`/`password_key`, so one secret can back multiple clusters (e.g. a primary DB and a test DB):

```json
{
  "DB_USERNAME": "admin",
  "DB_PASSWORD": "<generated>",
  "DB_TEST_USERNAME": "test",
  "DB_TEST_PASSWORD": "<generated>"
}
```

Subnet IDs, security group IDs, the KMS key ARN, and the credentials secret ID come from Terragrunt `dependency` blocks or plain inputs.

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

dependency "kms" {
  config_path = "../kms"
}

inputs = {
  project     = "myapp"
  environment = "production"
  config_file = "${get_terragrunt_dir()}/config/config.yml"

  subnet_ids            = values(dependency.vpc.outputs.private_subnets)[*].id
  security_group_ids    = [dependency.sg.outputs.security_groups["rds"].id]
  kms_key_id            = dependency.kms.outputs.keys["rds"].arn
  credentials_secret_id = "myapp/production/rds-master"

  tags = {
    ManagedBy = "terraform"
  }
}
```

Before applying, create the shared credentials secret manually (e.g. via the AWS CLI or console — not Terraform):

```bash
aws secretsmanager create-secret \
  --name myapp/production/rds-master \
  --secret-string '{
    "DB_USERNAME": "admin",
    "DB_PASSWORD": "<generated>",
    "DB_TEST_USERNAME": "test",
    "DB_TEST_PASSWORD": "<generated>",
    "DB_PROD_USERNAME": "admin",
    "DB_PROD_PASSWORD": "<generated>"
  }'
```

### config/config.yml

```yaml
clusters:
  main:
    engine: aurora-postgresql
    engine_version: "16.4"
    database_name: myapp
    username_key: DB_USERNAME
    password_key: DB_PASSWORD
    min_capacity: 0.5
    max_capacity: 8
    instances: 1
    backup_retention_period: 7
    deletion_protection: false
    skip_final_snapshot: true
  test:
    engine: aurora-postgresql
    engine_version: "16.4"
    database_name: myapp_test
    username_key: DB_TEST_USERNAME
    password_key: DB_TEST_PASSWORD
    min_capacity: 0.5
    max_capacity: 2
    instances: 1
    backup_retention_period: 1
    deletion_protection: false
    skip_final_snapshot: true
  # Production: 2 instances (writer + reader), higher ceiling for traffic
  # spikes, longer backup retention, and guarded against accidental deletion.
  production:
    engine: aurora-postgresql
    engine_version: "16.4"
    database_name: myapp_production
    username_key: DB_PROD_USERNAME
    password_key: DB_PROD_PASSWORD
    min_capacity: 1
    max_capacity: 16
    instances: 2
    backup_retention_period: 30
    deletion_protection: true
    skip_final_snapshot: false
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
| `kms_key_id` | ARN of the KMS key used to encrypt cluster storage (from `resources/kms`) | `string` | — | yes |
| `credentials_secret_id` | Name or ARN of the single manually-created Secrets Manager secret holding all clusters' credentials | `string` | — | yes |
| `tags` | Tags applied to all resources | `map(string)` | `{}` | no |

### config.yml clusters fields

| Field | Description | Default |
|-------|-------------|---------|
| `engine` | Aurora engine (`aurora-postgresql` or `aurora-mysql`) | `"aurora-postgresql"` |
| `engine_version` | Engine version (e.g. `"16.4"`) | required |
| `database_name` | Initial database name | required |
| `username_key` | Key within `credentials_secret_id`'s JSON holding this cluster's username | required |
| `password_key` | Key within `credentials_secret_id`'s JSON holding this cluster's password | required |
| `min_capacity` | Minimum ACU for Serverless v2 scaling (0.5–128) | `0.5` |
| `max_capacity` | Maximum ACU for Serverless v2 scaling (0.5–128) | `8` |
| `instances` | Number of cluster instances (writer + readers) | `1` |
| `backup_retention_period` | Days to retain automated backups | `7` |
| `deletion_protection` | Prevent accidental cluster deletion | `false` |
| `skip_final_snapshot` | Skip final snapshot on cluster deletion | `true` |

## Outputs

| Name | Description |
|------|-------------|
| `clusters` | Map of cluster key to `{ arn, endpoint, reader_endpoint, port, database_name, kms_key_id, username_key }` |

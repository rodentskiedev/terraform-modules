# resources/ecs/task_definition

Creates one or more ECS task definitions. Static settings (cpu, memory, launch type) live in a YAML config file. Each entry references a container definition JSON file by filename — both files live together in the caller's `config/` directory. The JSON file is processed with `templatefile()`, so it can reference `${region}` and `${log_group}` which are injected at plan time.

IAM role ARNs are passed as variables because they come from a separate IAM Terragrunt stack.

## Sample Terragrunt Usage

```hcl
terraform {
  source = "git::https://github.com/<org>/terraform-modules.git//resources/ecs/task_definition?ref=v0.0.1"
}

include "root" {
  path = find_in_parent_folders()
}

dependency "iam" {
  config_path = "../iam"
}

inputs = {
  project            = "myapp"
  environment        = "production"
  config_file        = "${get_terragrunt_dir()}/config/config.yml"
  execution_role_arn = dependency.iam.outputs.roles["ecs_execution"].arn
  task_role_arn      = dependency.iam.outputs.roles["ecs_task"].arn

  tags = {
    ManagedBy = "terraform"
  }
}
```

### config/config.yml

```yaml
task_definitions:
  app:
    cpu: 256
    memory: 512
    network_mode: awsvpc
    requires_compatibilities:
      - FARGATE
    container_definitions: task_definition.json
```

### config/task_definition.json

The JSON file is a standard ECS container definition array. Use `${region}` and `${log_group}` as template placeholders — they are injected automatically. The log group resolves to `/ecs/<project>-<key>-<environment>`.

```json
[
  {
    "name": "app",
    "image": "httpd:latest",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 80,
        "protocol": "tcp"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${log_group}",
        "awslogs-region": "${region}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
```

> If your container definition contains literal `${...}` that are not template variables (e.g. environment variable syntax), escape them as `$${...}`.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `region` | AWS region to use for the provider | `string` | `"ap-southeast-1"` | no |
| `project` | Project name, used as a prefix for resource names | `string` | — | yes |
| `environment` | Deployment environment | `string` | `"develop"` | no |
| `config_file` | Absolute path to the YAML config file | `string` | — | yes |
| `execution_role_arn` | IAM role ARN the ECS agent uses to pull images and publish logs | `string` | — | yes |
| `task_role_arn` | IAM role ARN the container uses for AWS API calls | `string` | `null` | no |
| `tags` | Tags applied to all task definitions | `map(string)` | `{}` | no |

### config.yml task_definitions fields

| Field | Description | Default |
|-------|-------------|---------|
| `cpu` | CPU units (256, 512, 1024, 2048, 4096) | `256` |
| `memory` | Memory in MB | `512` |
| `network_mode` | Docker network mode | `"awsvpc"` |
| `requires_compatibilities` | Launch type (`FARGATE` or `EC2`) | `["FARGATE"]` |
| `container_definitions` | Filename of the container definition JSON (resolved relative to the config file) | required |

## Outputs

| Name | Description |
|------|-------------|
| `task_definitions` | Map of task definition key to `{ arn, family, revision }` |

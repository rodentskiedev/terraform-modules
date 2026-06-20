variable "region" {
  description = "AWS region to use for the provider."
  type        = string
  default     = "ap-southeast-1"
}

variable "project" {
  description = "Project name, used as a prefix for resource names."
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g. develop, staging, production)."
  type        = string
  default     = "develop"
}

variable "config_file" {
  description = "Path to the YAML configuration file defining task definitions and their container definition JSON filenames."
  type        = string
}

variable "execution_role_arn" {
  description = "IAM role ARN the ECS agent uses to pull images and publish logs to CloudWatch."
  type        = string
}

variable "task_role_arn" {
  description = "IAM role ARN the container process uses for AWS API calls. Leave null if the container needs no AWS permissions."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to all task definitions."
  type        = map(string)
  default     = {}
}

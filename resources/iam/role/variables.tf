variable "region" {
  description = "AWS region to use for the provider."
  type        = string
  default     = "ap-southeast-1"
}

variable "project" {
  description = "Project name, used as a prefix for role names."
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g. develop, staging, production)."
  type        = string
  default     = "develop"
}

variable "config_file" {
  description = "Path to the YAML configuration file defining IAM roles."
  type        = string
}

variable "tags" {
  description = "Tags applied to all IAM roles."
  type        = map(string)
  default     = {}
}

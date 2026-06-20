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

variable "tags" {
  description = "Tags applied to all listener rules."
  type        = map(string)
  default     = {}
}

variable "listener_rules" {
  description = "Map of listener rules to create. The key is used as the name suffix and resource identifier."
  type = map(object({
    listener_arn     = string
    priority         = number
    target_group_arn = string
    conditions = list(object({
      type   = string
      values = list(string)
    }))
  }))
}

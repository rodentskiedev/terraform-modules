variable "region" {
  description = "AWS region to use for the provider."
  type        = string
  default     = "ap-southeast-1"
}

variable "instance_arn" {
  description = "ARN of the IAM Identity Center instance."
  type        = string
}

variable "assignments" {
  description = "Map of account assignments to create. Each entry grants a group a permission set on an AWS account. The key is used as a unique identifier."
  type = map(object({
    account_id         = string
    group_id           = string
    permission_set_arn = string
  }))
}

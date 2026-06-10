variable "region" {
  description = "AWS region to use for the provider."
  type        = string
  default     = "ap-southeast-1"
}

variable "tags" {
  description = "Tags to apply to each organizational unit."
  type        = map(string)
  default     = {}
}


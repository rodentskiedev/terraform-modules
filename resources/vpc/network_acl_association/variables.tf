variable "region" {
  description = "AWS region to use for the provider."
  type        = string
  default     = "ap-southeast-1"
}

variable "network_acl_associations" {
  description = "Map of Network ACL associations to create. The key is used as a unique identifier."
  type = map(object({
    network_acl_id = string
    subnet_id      = string
  }))
}

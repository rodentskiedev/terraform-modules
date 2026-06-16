variable "region" {
  description = "AWS region to use for the provider."
  type        = string
  default     = "ap-southeast-1"
}

variable "network_acl_rules" {
  description = "Map of Network ACL rules to create. The key is used as a unique identifier."
  type = map(object({
    network_acl_id = string
    rule_number    = number
    egress         = bool
    protocol       = string
    rule_action    = string
    cidr_block     = optional(string)
    from_port      = optional(number)
    to_port        = optional(number)
    icmp_type      = optional(number)
    icmp_code      = optional(number)
  }))
}

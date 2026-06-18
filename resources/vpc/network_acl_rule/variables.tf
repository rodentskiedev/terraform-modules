variable "region" {
  description = "AWS region to use for the provider."
  type        = string
  default     = "ap-southeast-1"
}

variable "public_network_acl_id" {
  description = "ID of the public Network ACL to attach rules to."
  type        = string
}

variable "private_network_acl_id" {
  description = "ID of the private Network ACL to attach rules to."
  type        = string
}

variable "public_rules" {
  description = "Map of rules to apply to the public Network ACL. The key is used as a unique identifier."
  type = map(object({
    rule_number = number
    egress      = bool
    protocol    = string
    rule_action = string
    cidr_block  = optional(string)
    from_port   = optional(number)
    to_port     = optional(number)
    icmp_type   = optional(number)
    icmp_code   = optional(number)
  }))
  default = {}
}

variable "private_rules" {
  description = "Map of rules to apply to the private Network ACL. The key is used as a unique identifier."
  type = map(object({
    rule_number = number
    egress      = bool
    protocol    = string
    rule_action = string
    cidr_block  = optional(string)
    from_port   = optional(number)
    to_port     = optional(number)
    icmp_type   = optional(number)
    icmp_code   = optional(number)
  }))
  default = {}
}

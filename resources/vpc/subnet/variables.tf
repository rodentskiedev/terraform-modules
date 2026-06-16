variable "region" {
  description = "AWS region to use for the provider."
  type        = string
  default     = "ap-southeast-1"
}

variable "subnets" {
  description = "Map of subnets to create. The key is used as a unique identifier."
  type = map(object({
    vpc_id                  = string
    cidr_block              = string
    availability_zone       = string
    map_public_ip_on_launch = optional(bool, false)
    tags                    = optional(map(string), {})
  }))
}

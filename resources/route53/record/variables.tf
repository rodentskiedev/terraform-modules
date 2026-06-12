variable "region" {
  description = "AWS region to use for the provider."
  type        = string
  default     = "ap-southeast-1"
}

variable "records" {
  description = "Map of Route53 records to create. The key is used as a unique identifier."
  type = map(object({
    zone_id = string
    name    = string
    type    = string
    ttl     = optional(number, 300)
    values  = list(string)
  }))
}

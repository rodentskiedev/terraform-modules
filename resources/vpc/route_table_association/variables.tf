variable "region" {
  description = "AWS region to use for the provider."
  type        = string
  default     = "ap-southeast-1"
}

variable "route_table_associations" {
  description = "Map of route table associations to create. The key is used as a unique identifier."
  type = map(object({
    subnet_id      = string
    route_table_id = string
  }))
}

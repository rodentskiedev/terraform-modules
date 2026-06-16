output "subnets" {
  description = "Map of subnet key to subnet attributes."
  value = {
    for key, subnet in aws_subnet.this : key => {
      id                = subnet.id
      cidr_block        = subnet.cidr_block
      availability_zone = subnet.availability_zone
      vpc_id            = subnet.vpc_id
    }
  }
}

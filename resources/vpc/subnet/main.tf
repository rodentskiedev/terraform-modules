data "aws_availability_zones" "this" {
  state = "available"
}

locals {
  public_subnet_map  = { for idx, cidr in var.public_cidrs : data.aws_availability_zones.this.names[idx] => cidr }
  private_subnet_map = { for idx, cidr in var.private_cidrs : data.aws_availability_zones.this.names[idx] => cidr }
}

resource "aws_subnet" "public" {
  for_each = local.public_subnet_map

  vpc_id                  = var.vpc_id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = true
  tags                    = merge(var.tags, { Name = "public-${each.key}" })
}

resource "aws_subnet" "private" {
  for_each = local.private_subnet_map

  vpc_id                  = var.vpc_id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = false
  tags                    = merge(var.tags, { Name = "private-${each.key}" })
}

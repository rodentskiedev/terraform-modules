resource "aws_route_table_association" "this" {
  for_each = var.route_table_associations

  subnet_id      = each.value.subnet_id
  route_table_id = each.value.route_table_id
}

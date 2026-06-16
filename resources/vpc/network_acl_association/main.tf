resource "aws_network_acl_association" "this" {
  for_each = var.network_acl_associations

  network_acl_id = each.value.network_acl_id
  subnet_id      = each.value.subnet_id
}

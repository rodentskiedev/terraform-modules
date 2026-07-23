resource "aws_iam_openid_connect_provider" "this" {
  for_each = var.oidc_providers

  url             = each.value.url
  client_id_list  = each.value.client_id_list
  thumbprint_list = each.value.thumbprint_list

  tags = merge(var.tags, each.value.tags, {
    Name = each.key
  })
}

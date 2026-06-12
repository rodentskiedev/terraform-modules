resource "aws_ssoadmin_account_assignment" "this" {
  for_each = var.assignments

  instance_arn       = var.instance_arn
  permission_set_arn = each.value.permission_set_arn

  target_id   = each.value.account_id
  target_type = "AWS_ACCOUNT"

  principal_id   = each.value.group_id
  principal_type = "GROUP"
}

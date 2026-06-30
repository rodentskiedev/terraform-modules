locals {
  config     = yamldecode(file(var.config_file))
  config_dir = dirname(var.config_file)
  policies   = local.config.policies
}

resource "aws_iam_policy" "this" {
  for_each = local.policies

  name        = "${var.project}-${each.key}-${var.environment}"
  description = try(each.value.description, null)
  policy      = try(each.value.policy_json, file("${local.config_dir}/${each.value.policy_file}"))

  tags = merge(var.tags, try(each.value.tags, {}), {
    Name = "${var.project}-${each.key}-${var.environment}"
  })
}

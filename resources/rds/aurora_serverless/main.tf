locals {
  config   = yamldecode(file(var.config_file))
  clusters = local.config.clusters

  # Flatten instances per cluster so each gets a stable for_each key.
  cluster_instances = merge([
    for cluster_key, cluster in local.clusters : {
      for i in range(try(cluster.instances, 1)) :
      "${cluster_key}-${i}" => { cluster_key = cluster_key, index = i }
    }
  ]...)
}

resource "aws_db_subnet_group" "this" {
  for_each = local.clusters

  name        = "${var.project}-${each.key}-${var.environment}"
  description = "Subnet group for ${var.project}-${each.key}-${var.environment}"
  subnet_ids  = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${var.project}-${each.key}-${var.environment}"
  })
}

resource "aws_rds_cluster" "this" {
  for_each = local.clusters

  cluster_identifier          = "${var.project}-${each.key}-${var.environment}"
  engine                      = try(each.value.engine, "aurora-postgresql")
  engine_version              = each.value.engine_version
  engine_mode                 = "provisioned"
  database_name               = each.value.database_name
  master_username             = each.value.master_username
  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.this[each.key].name
  vpc_security_group_ids = var.security_group_ids

  serverlessv2_scaling_configuration {
    min_capacity = try(each.value.min_capacity, 0.5)
    max_capacity = try(each.value.max_capacity, 8)
  }

  backup_retention_period = try(each.value.backup_retention_period, 7)
  deletion_protection     = try(each.value.deletion_protection, false)
  skip_final_snapshot     = try(each.value.skip_final_snapshot, true)

  tags = merge(var.tags, {
    Name = "${var.project}-${each.key}-${var.environment}"
  })
}

resource "aws_rds_cluster_instance" "this" {
  for_each = local.cluster_instances

  identifier         = "${var.project}-${each.value.cluster_key}-${each.value.index}-${var.environment}"
  cluster_identifier = aws_rds_cluster.this[each.value.cluster_key].id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.this[each.value.cluster_key].engine
  engine_version     = aws_rds_cluster.this[each.value.cluster_key].engine_version

  tags = merge(var.tags, {
    Name = "${var.project}-${each.value.cluster_key}-${each.value.index}-${var.environment}"
  })
}

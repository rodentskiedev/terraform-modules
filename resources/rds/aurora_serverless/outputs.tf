output "clusters" {
  description = "Map of cluster key to cluster attributes."
  value = {
    for key, cluster in aws_rds_cluster.this : key => {
      arn                    = cluster.arn
      endpoint               = cluster.endpoint
      reader_endpoint        = cluster.reader_endpoint
      port                   = cluster.port
      database_name          = cluster.database_name
      master_username        = cluster.master_username
      master_user_secret_arn = cluster.master_user_secret[0].secret_arn
    }
  }
}

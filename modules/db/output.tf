output "cluster_endpoint" {
  description = "The cluster endpoint"
  value       = aws_rds_cluster.mysql.endpoint
}

output "reader_endpoint" {
  description = "The cluster reader endpoint"
  value       = aws_rds_cluster.mysql.reader_endpoint
}

output "database_name" {
  description = "The database name"
  value       = aws_rds_cluster.mysql.database_name
}
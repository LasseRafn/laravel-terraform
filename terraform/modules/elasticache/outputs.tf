output "elasticache_ip" {
  value = "${aws_elasticache_cluster.app.cluster_address}"
}

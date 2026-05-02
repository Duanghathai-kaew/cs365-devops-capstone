output "cluster_name" {
  value = try(aws_eks_cluster.eks[0].name, null)
}

output "cluster_endpoint" {
  value = try(aws_eks_cluster.eks[0].endpoint, null)
}

output "cluster_version" {
  value = try(aws_eks_cluster.eks[0].version, null)
}
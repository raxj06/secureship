output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_arn" {
  value = module.eks.cluster_arn
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "node_group_arn" {
  value = try(module.eks.eks_managed_node_groups["spot"].node_group_arn, null)
}

output "eso_role_arn" {
  value = aws_iam_role.eso.arn
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

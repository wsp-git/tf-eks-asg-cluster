output "region" {
  description = "AWS region."
  value       = var.region
}

output "cluster_name" {
  description = "Show cluster name"
  value       = local.cluster_name
}

output "cluster_endpoint" {
  description = "EKS endpoint"
  value       = module.eks.cluster_endpoint
}

output "kubeconfig" {
  description = "config for kubectl"
  value       = module.eks.kubeconfig
}

output "config_map_aws_auth" {
  description = "authentication to cluster configuration"
  value       = module.eks.config_map_aws_auth
}

output "cluster_security_group_id" {
  description = "control plane security groups."
  value       = module.eks.cluster_security_group_id
}

output "latest_eks_ami" {
  value       = data.aws_ami.eks_ami.id
  description = "Latest found EKS image"
}

output "k8s_arn" {
  value       = aws_iam_policy.cluster_autoscaler.arn
  description = "Get ARN for helm chart"
}
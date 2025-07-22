output "external_secrets_role_arn" {
  value = module.irsa.external_secrets_role_arn
}

output "eks_connection_command" {
  description = "command to connect to the EKS cluster"
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
}
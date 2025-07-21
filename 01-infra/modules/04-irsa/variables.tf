variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "oidc_provider_arn" {
  type        = string
  description = "ARN of the IAM OIDC provider"
}

variable "oidc_provider_url" {
  type        = string
  description = "URL of the OIDC provider (without https://)"
}

variable "secret_arns" {
  description = "ARN in Secret Manager"
  type        = list(string)
}
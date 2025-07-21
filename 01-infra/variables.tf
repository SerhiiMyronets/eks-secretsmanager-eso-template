
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "domain_name" {
  type        = string
  description = "Domain name for certificate, e.g. example.com"
  default     = "serhii.link"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b" /*, "us-east-1c"*/] // commented for $ saving (NAT + EIP)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24" /*, "10.0.3.0/24"*/] // commented for $ saving (NAT + EIP)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24" /*, "10.0.6.0/24"*/] // commented for $ saving (NAT + EIP)
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "my-eks-cluster"
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.32"
}

variable "node_groups_config" {
  description = "EKS node group configuration"
  type = map(object({
    instance_types = list(string)
    capacity_type  = string
    scaling_config = object({
      desired_size = number
      max_size     = number
      min_size     = number
    })
  }))
  default = {
    general = {
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
      scaling_config = {
        desired_size = 2
        max_size     = 2
        min_size     = 1
      }
    }
  }
}

variable "rds_config" {
  description = "RDS configuration"
  type = object({
    db_name           = string
    db_username       = string
    engine            = string
    engine_version    = string
    port              = number
    instance_class    = string
    allocated_storage = number
  })
  default = {
    db_name           = "usermgmtdb"
    db_username       = "dbadmin"
    engine            = "mysql"
    engine_version    = "8.0"
    port              = 3306
    instance_class    = "db.t3.micro"
    allocated_storage = 20
  }
}
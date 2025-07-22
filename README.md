# Terraform Setup for EKS + Secrets Manager + ESO

A minimal and extensible infrastructure template for integrating AWS Secrets Manager with External Secrets Operator (ESO) in EKS, provisioned via Terraform.

This repository provisions an EKS cluster with IRSA roles, an RDS instance, and sets up ESO to sync secrets from Secrets Manager. It includes an example with a test pod and MySQL client to demonstrate secret injection.

Helm values and Kubernetes manifests are rendered automatically using `gomplate`, enabling GitOps-friendly workflows.

The goal is to keep the setup simple, reproducible, and aligned with how External Secrets Operator and AWS Secrets Manager are typically used in production environments.

### ✦ Features

* Terraform-driven provisioning of EKS, IAM, Secrets Manager, and RDS
* Secure secret delivery to Kubernetes via External Secrets Operator
* MySQL test deployment to verify secrets injection
* gomplate-based rendering of Helm values and Kubernetes manifests
* GitOps-compatible layout with rendered files ready for Argo CD or `kubectl apply`

---

## 📁 Repository Structure

```
.
├── 01-infra                # Terraform config for EKS and dependencies
│   ├── main.tf
│   ├── outputs.tf
│   ├── providers.tf
│   ├── variables.tf
│   └── modules/            # Infrastructure modules
│       ├── 01-vpc/         # VPC with public and private subnets
│       ├── 02-eks/         # EKS cluster and node group
│       ├── 03-rds/         # RDS MySQL instance
│       └── 04-irsa/        # IAM Roles for Service Accounts (IRSA)
├── 02-render               # gomplate rendering engine
│   ├── render.sh           # Script to render manifests
│   └── templates/          # gomplate templates for Helm values
├── 03-install              # Output manifests and Helm values
│   ├── helm-values/        # Rendered Helm values for installation
│   └── manifests/          # Kubernetes manifests ready for apply
├── docs/
│   └── screenshots/        # Optional screenshots for documentation
```

---

## 🚀 Usage

### 1. Provision Infrastructure

```bash
cd 01-infra
terraform init
terraform apply
```

This will provision EKS, IRSA roles, and RDS.

### 2. Render Templates

```bash
cd 02-render
./render.sh
```

### 3. Install ESO and Deploy Resources

```bash
kubectl apply -f 03-install/manifests/
```

---

## 🧪 Verify Secrets

```bash
kubectl logs deploy/test-deployment

kubectl exec -it deploy/mysql-deployment -- mysql -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD"
```

---

## 📸 Screenshots

---

## 📜 License

MIT © [Serhii Myronets](https://github.com/serhii-myronets)

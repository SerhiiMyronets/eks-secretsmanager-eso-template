# Terraform Setup for EKS + Secrets Manager + ESO

A minimal and extensible infrastructure template that demonstrates how to inject and rotate secrets from AWS Secrets Manager into Kubernetes using External Secrets Operator (ESO), fully provisioned with Terraform.

This repository provisions an EKS cluster, sets up IAM roles via IRSA, and deploys an RDS MySQL database with automated password rotation using AWS Lambda. It integrates ESO to expose secrets from AWS Secrets Manager to Kubernetes workloads securely. The setup also includes test deployments for validation.

Helm values and Kubernetes manifests are rendered using `gomplate` based on Terraform outputs, enabling a clean GitOps-friendly deployment workflow.

The goal is to keep the setup simple, reproducible, and aligned with how External Secrets Operator and AWS Secrets Manager are typically used in production environments.

### ✦ Features

* Complete EKS and VPC provisioning via Terraform
* RDS MySQL instance with random password generation and AWS-managed rotation
* Lambda function for automatic password rotation via Secrets Manager
* External Secrets Operator installed and configured with IRSA permissions
* gomplate-powered rendering of Helm values and Kubernetes manifests
* Sample workloads that consume secrets and validate integration (e.g. MySQL client, log printer)

---

## 📁 Repository Structure

```
.
├── 01-infra                # Terraform code for core AWS infrastructure
│   ├── main.tf
│   ├── outputs.tf
│   ├── providers.tf
│   ├── variables.tf
│   └── modules/            # Reusable Terraform modules
│       ├── 01-vpc/         # VPC with public/private subnets (same as Karpenter template)
│       ├── 02-eks/         # EKS cluster and node group (same as Karpenter template)
│       ├── 03-rds/         # RDS MySQL instance, password secret, Lambda rotation
│       └── 04-irsa/        # IRSA role with policy for ESO access to Secrets Manager
├── 02-render               # gomplate rendering engine
│   ├── render.sh           # Script to render manifests from Terraform outputs
│   └── templates/          # gomplate templates for ESO Helm values
├── 03-install              # Output manifests and Helm values
│   ├── helm-values/        # Rendered Helm values for installation
│   └── manifests/          # ClusterSecretStore, ExternalSecret, tests
├── docs/
│   └── screenshots/        # Optional screenshots
```

---

## 🚀 Usage

### 1. Provision Infrastructure

```bash
cd 01-infra
terraform init
terraform apply
```

This step creates the VPC, EKS cluster, IRSA roles, RDS MySQL instance, secret in Secrets Manager, Lambda function for password rotation, and rotation configuration.

### 2. Render Templates

```bash
cd 02-render
./render.sh
```

This script will:

* Pull values from Terraform outputs (ARNs, secret names, etc.)
* Generate Helm `values.yaml` for ESO chart
* Place rendered files in `03-install/`

### 3. Install ESO and Kubernetes Resources

```bash
# Install ESO Helm chart
helm upgrade --install external-secrets external-secrets/external-secrets \
  -n external-secrets --create-namespace \
  -f 03-install/helm-values/external-secrets-values.yaml

# Apply core manifests
kubectl apply -f 03-install/manifests/
```

---

## 🧪 Verify Secrets Integration

Test deployment reads secrets and prints them to logs:

```bash
kubectl logs deploy/test-deployment
```

MySQL client pod connects to the rotated password in the RDS database:

```bash
kubectl exec -it deploy/mysql-deployment -- \
  mysql -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD"
```

---

## 📸 Screenshots

---

## 📜 License

MIT © [Serhii Myronets](https://github.com/serhii-myronets)

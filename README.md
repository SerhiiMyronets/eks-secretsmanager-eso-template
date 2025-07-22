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

## ✦ Prerequisites

The following tools must be available in your environment:

* **Terraform** — for provisioning AWS infrastructure
* **AWS CLI** — used by Terraform and general access to AWS
* **kubectl** — to apply Kubernetes manifests and interact with the cluster
* **gomplate** — for rendering manifests and Helm values from templates
* **Helm** — to install Karpenter into the cluster

---

## ⚙️ Setup Instructions

### 1. Provision Infrastructure

#### terraform.tfvars

You don't need to create a `terraform.tfvars` file unless you want to override the default configuration. All variables have safe and low-cost defaults, but for customization (such as region, AZs, or instance types), an example file `terraform.tfvars.example` is provided.

💡 The defaults are optimized for learning, demos, and minimal AWS costs.

This step provisions all core AWS resources: VPC, subnets, Internet Gateway, IAM roles, RDS MySQL database, AWS Lambda and the EKS cluster itself.

```bash
cd 01-infra
terraform init
terraform apply
```

Once complete, Terraform will produce a set of outputs that will be consumed by the next step.

Among the outputs, you will see a ready-to-run command for configuring your kubeconfig to access the cluster:

**aws eks update-kubeconfig --region <\<region\>> --name <\<cluster\_name>>**

This command is generated automatically based on your configuration.

---

### 2. Render Manifests

This step takes the Terraform outputs and uses them to generate Helm values using gomplate.

```bash
cd ../02-render
bash render.sh
```

The rendered files will be placed into `03-install/helm-values`.

---

### 3. Install ESO and Kubernetes Resources

```bash
cd ../03-install

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

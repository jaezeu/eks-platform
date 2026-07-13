# EKS Cluster Deployer Role

Terraform that creates the IAM role the GitHub Actions workflows assume (via
OIDC) to provision and tear down clusters. **This is the bootstrap step: run it
once before any cluster workflow.**

The role (`EKSPlatformDeployerRole`) is referenced by:

- [create-standard-cluster.yml](../../.github/workflows/create-standard-cluster.yml)
- [create-cilium-cluster.yml](../../.github/workflows/create-cilium-cluster.yml)
- [cleanup.yml](../../.github/workflows/cleanup.yml)

In CI this is applied by the
[create-deployer-role.yml](../../.github/workflows/create-deployer-role.yml)
workflow.

## What it creates

- An IAM role with a trust policy scoped to this repository, so workflows assume
  it via OIDC without long-lived AWS credentials.
- The role attaches the AWS-managed **`AdministratorAccess`** policy (broad, for
  a learning/demo account; tighten this for any shared or production account).

> [!IMPORTANT]
> The **GitHub OIDC provider is a shared, account-level prerequisite** (only one
> can exist per account) and is owned by the central account-bootstrap stack.
> This stack looks it up ([`data.tf`](data.tf)) rather than creating it, so the
> provider must already exist before you apply. If it does not, `plan` fails
> with "no OIDC provider found for URL".

## Usage

```bash
cd terraform/eks-cluster-deployer-role
terraform init
terraform plan
terraform apply
```

Review [`backend.tf`](backend.tf) for remote state configuration and
[`provider.tf`](provider.tf) for the target region/account before applying.
The role ARN is exposed via [`output.tf`](output.tf) for use in the workflows.

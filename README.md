# EKS Platform

A comprehensive AWS EKS (Elastic Kubernetes Service) platform repository designed for learning, demonstration, and bootstrapped cluster deployments. This repository provides Infrastructure as Code (IaC) using Terraform, essential Kubernetes add-ons via Helm, and example manifests for common deployment manifests.

## Table of Contents

- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Architecture Overview](#architecture-overview)
- [Repository Structure](#repository-structure)
- [Quick Start](#quick-start)
- [Contributing](#contributing)
- [License](#license)

## Introduction

This repository serves as an EKS demo and learning platform, providing:

- **EKS cluster configurations** with Terraform
- **Multiple deployment modes**: Standard EKS and Cilium CNI (kube-proxy free)
- **Essential add-ons**: Monitoring (Prometheus/Loki), Ingress (NGINX), GitOps (ArgoCD), Security (Cert-Manager), and more
- **Example manifests**: Service types, deployments, ingress patterns, and troubleshooting tools (netshoot)
- **IRSA (IAM Roles for Service Accounts)** for secure AWS resource access

## Prerequisites

### Required Tools

Ensure the following tools are installed and properly configured:

| Tool | Minimum Version | Purpose |
|------|----------------|---------|
| [AWS CLI](https://aws.amazon.com/cli/) | v2.x | AWS resource management |
| [Terraform](https://www.terraform.io/downloads) | v1.5+ | Infrastructure provisioning |
| [kubectl](https://kubernetes.io/docs/tasks/tools/) | v1.28+ | Kubernetes cluster management |
| [Helm](https://helm.sh/docs/intro/install/) | v3.12+ | Kubernetes package management |

### AWS Prerequisites

- **AWS Account** with appropriate permissions
- **IAM User/Role** with permissions to create:
  - EKS clusters
  - VPC and networking resources
  - IAM roles and policies
  - EC2 instances (for node groups)
  - S3 buckets (for Loki, if enabled)
  - Route53 records (for ExternalDNS, if enabled)
- **AWS CLI configured** with a named profile or default credentials:
  ```bash
  aws configure --profile <your-profile>
  ```

### Recommended Knowledge

- Basic understanding of Kubernetes concepts
- Familiarity with Terraform and IaC principles
- AWS networking (VPC, subnets, security groups)

## Architecture Overview

This repository supports two EKS networking architectures:

### Standard EKS Cluster
- Uses AWS VPC CNI for pod networking
- Includes kube-proxy for service load balancing
- Requires VPC CNI & kubeproxy to be up before attaching node groups
- Best for: General-purpose workloads and learning

### Cilium-Based EKS Cluster (Kube-Proxy Free)
- Uses Cilium CNI in ENI mode
- Replaces kube-proxy with eBPF for improved performance
- Requires Cilium installation before node groups become healthy
- Best for: High-performance networking, security policies, observability

## Repository Structure

| Directory | Purpose |
|-----------|---------|
| **.github/** | GitHub automation and CI/CD workflows |
| └── **workflows/** | GitHub Actions for cluster lifecycle and Terraform validation |
| **terraform/** | Terraform IaC for EKS cluster provisioning |
| ├── **eks-cluster/** | Main EKS cluster configuration with VPC, node groups, and IRSA resources |
| ├── **eks-cluster-deployer-role/** | IAM role for automated cluster deployment |
| **addons/** | Helm charts and configurations for cluster add-ons |
| ├── **argocd/** | GitOps continuous delivery tool |
| ├── **cert-manager/** | X.509 certificate management for TLS |
| ├── **cilium/** | eBPF-based CNI with network policies and observability |
| ├── **ebs-csi-driver/** | Amazon EBS CSI driver for persistent volumes |
| ├── **kube-prometheus-stack/** | Prometheus, Grafana, and Alertmanager for monitoring |
| ├── **loki/** | Log aggregation system |
| ├── **nginx-ingress/** | NGINX Ingress Controller for HTTP(S) routing |
| ├── **r53-externaldns/** | Automatic DNS record management with Route53 |
| **applications/** | Sample applications for testing and learning |
| ├── **postgres/** | PostgreSQL database deployment |
| ├── **wordpress/** | WordPress application with database |
| **deployment-manifests-examples/** | Example Kubernetes manifests for various use cases |
| ├── **eks-basic-deployment-with-service-account/** | Basic deployment with IRSA |
| ├── **eks-service-types/** | ClusterIP, NodePort, LoadBalancer examples |
| ├── **ingress-coaching/** | Ingress configuration examples |
| ├── **learner-prometheus/** | Custom Prometheus deployment for learning |

## Quick Start

It is recommended to make use of the workflows in `.github/workflows` for cluster creation/destruction.

- `.github/workflows/create-deployer-role.yml` - Create IAM role required to run the 2 workflows below.
- `.github/workflows/create-cilium-cluster.yml` - EKS cluster creation with Cilium CNI & Addons
- `.github/workflows/create-standard-cluster.yml` - EKS standard cluster creation with VPC CNI & Addons
- `.github/workflows/cleanup.yml` - Destruction of all cluster related resources

Once the cluster is created, you may use the command line shown below to access your cluster.

```bash
aws eks update-kubeconfig --name <your-cluster-name> --region <your-region> --profile <your-profile>
```

### Verify Cluster Access

```bash
# List all nodes
kubectl get nodes

# Verify add-ons
kubectl get pods -A
```

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on:
- Reporting bugs
- Suggesting enhancements
- Submitting pull requests
- Code style and structure

## License

This project is licensed under the terms specified in the [LICENSE](LICENSE) file.

# EKS Platform

[![Terraform Checks](https://github.com/jaezeu/eks-platform/actions/workflows/terraform-checks.yml/badge.svg)](https://github.com/jaezeu/eks-platform/actions/workflows/terraform-checks.yml)
![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.14-7B42BC?logo=terraform&logoColor=white)
![Kubernetes](https://img.shields.io/badge/EKS-v1.36-326CE5?logo=kubernetes&logoColor=white)
![Cilium](https://img.shields.io/badge/Cilium-1.20--pre-F8C517?logo=cilium&logoColor=black)
![Gateway API](https://img.shields.io/badge/Gateway%20API-v1.5%20%2B%20ListenerSet-326CE5?logo=kubernetes&logoColor=white)
![Helm](https://img.shields.io/badge/Helm-v3-0F1689?logo=helm&logoColor=white)
![License](https://img.shields.io/badge/License-see%20LICENSE-blue)

A comprehensive AWS EKS (Elastic Kubernetes Service) platform repository designed for learning, demonstration, and bootstrapped cluster deployments. This repository provides Infrastructure as Code (IaC) using Terraform, essential Kubernetes add-ons via Helm, and example manifests for common deployment patterns.

> [!WARNING]
> **This provisions billable AWS resources** — an EKS control plane, ARM64 EC2
> node groups, a NAT gateway, load balancers and S3 buckets. Costs accrue while
> the cluster runs. Tear everything down with the
> [`cleanup.yml`](.github/workflows/cleanup.yml) workflow when you are done.

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
- **Two north-south traffic models**: classic NGINX Ingress (standard cluster) and **Gateway API with per-team ListenerSets** (Cilium cluster) — including standard-channel `ListenerSet`, which only shipped in Gateway API v1.5 / Cilium 1.20
- **Essential add-ons**: Monitoring (Prometheus/Loki), GitOps (ArgoCD), Security (Cert-Manager, Kyverno), and more
- **Example manifests**: Service types, deployments, Ingress *and* Gateway API patterns, and troubleshooting tools (netshoot)
- **IRSA (IAM Roles for Service Accounts)** for secure AWS resource access

## Prerequisites

### Required Tools

Ensure the following tools are installed and properly configured:

| Tool | Minimum Version | Purpose |
|------|----------------|---------|
| [AWS CLI](https://aws.amazon.com/cli/) | v2.x | AWS resource management |
| [Terraform](https://www.terraform.io/downloads) | v1.14+ | Infrastructure provisioning |
| [kubectl](https://kubernetes.io/docs/tasks/tools/) | v1.35+ | Kubernetes cluster management (cluster runs v1.36) |
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

![Platform architecture overview](docs/images/platform-overview.png)

The platform provisions an EKS cluster inside a dedicated VPC, with managed
node groups in private subnets, an in-cluster add-on layer (ingress,
monitoring, GitOps, logging), and IRSA roles granting least-privilege access
to AWS services such as Route 53 and S3.

This repository supports two EKS networking architectures. Use this to decide:

| Feature | **Standard** | **Cilium (kube-proxy free)** |
|---|---|---|
| CNI | AWS VPC CNI | Cilium (ENI mode) |
| Service routing | kube-proxy (iptables) | eBPF datapath |
| Observability | Add-ons only | + Hubble (flow visibility) |
| Runtime security | Add-ons only | + Tetragon |
| mTLS / identity | - | + SPIRE (mutual auth) |
| Ingress | NGINX Ingress | Gateway API (shared `Gateway` + per-app `ListenerSet`) |
| Bootstrap | Single `terraform apply` | Split apply (CNI before nodes) |
| Choose it for | General-purpose workloads, learning | High-performance networking, security & observability deep-dives |

![Standard VPC CNI vs Cilium eBPF networking](docs/images/networking-modes.png)

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

The Cilium deployment bundles a full eBPF stack — Hubble for flow visibility,
Tetragon for runtime security, SPIRE for mutual (mTLS) authentication, and the
Gateway API for ingress:

![Cilium stack deep dive](docs/images/cilium-architecture.png)

### Gateway API with ListenerSets (Cilium cluster)

The Cilium cluster replaces per-app Ingress objects with the Gateway API's
**self-service listener** model, using standard-channel
[`ListenerSet`](https://gateway-api.sigs.k8s.io/) — a resource that graduated
in Gateway API v1.5 and is implemented by Cilium as of 1.20:

- The platform owns **one shared `Gateway`** ([addons/cilium/gateway/](addons/cilium/gateway/))
  with a single `:80` listener (ACME HTTP-01 challenges) and
  `allowedListeners: All`.
- Each app attaches its **own HTTPS listener + TLS cert + route** from its own
  namespace with a `ListenerSet` + `HTTPRoute` pair — no change to the shared
  Gateway, no cluster-admin involvement. ArgoCD, Prometheus, Grafana and
  Hubble UI are all exposed this way (see `addons/*/gateway-route.yaml`).
- cert-manager issues certs straight off the ListenerSet annotation
  (HTTP-01 via `gatewayHTTPRoute`), and ExternalDNS publishes each route's
  hostname — the whole chain is hands-off.

The [gateway-api-coaching](deployment-manifests-examples/gateway-api-coaching/)
example walks through the same pattern side by side with its classic
[ingress-coaching](deployment-manifests-examples/ingress-coaching/) equivalent.

> Diagrams are generated as code with [`diagrams`](https://diagrams.mingrammer.com/);
> see [docs/diagrams/](docs/diagrams/) to regenerate them.

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
| ├── **kyverno/** | Policy engine enforcing the [guardrail policies](kyverno-policies/) |
| ├── **loki/** | Log aggregation system |
| ├── **nginx-ingress/** | NGINX Ingress Controller for HTTP(S) routing |
| ├── **r53-externaldns/** | Automatic DNS record management with Route53 |
| **applications/** | Sample applications for testing and learning |
| ├── **postgres/** | PostgreSQL database deployment |
| ├── **wordpress/** | WordPress application with database |
| **deployment-manifests-examples/** | Example Kubernetes manifests for various use cases |
| ├── **eks-basic-deployment-with-service-account/** | Basic deployment with IRSA |
| ├── **eks-service-types/** | ClusterIP, NodePort, LoadBalancer examples |
| ├── **gateway-api-coaching/** | Gateway API (ListenerSet + HTTPRoute) examples — Cilium cluster |
| ├── **ingress-coaching/** | Ingress configuration examples — standard cluster |
| ├── **learner-prometheus/** | Custom Prometheus deployment for learning |
| **kyverno-policies/** | Cluster-wide Kyverno admission policies (guardrails) |
| **scripts/** | Helper scripts (e.g. learner namespace provisioning) |
| **docs/** | Architecture diagrams (as code) and rendered images |

## Quick Start

The cluster is bootstrapped in a fixed order — deployer role, Terraform, CNI,
node groups, add-ons, then workloads:

![Cluster bootstrap flow](docs/images/bootstrap-flow.png)

It is recommended to make use of the workflows in `.github/workflows` for cluster creation/destruction.

- `.github/workflows/create-deployer-role.yml` - Create IAM role required to run the 2 workflows below.
- `.github/workflows/create-cilium-cluster.yml` - EKS cluster creation with Cilium CNI & Addons
- `.github/workflows/create-standard-cluster.yml` - EKS standard cluster creation with VPC CNI & Addons
- `.github/workflows/cleanup.yml` - Destruction of all cluster related resources

> [!NOTE]
> **The deployer role uses `AdministratorAccess`.** This is a deliberate
> tradeoff for a sandbox teaching account: the workflows create IAM roles, VPCs,
> EKS clusters and S3 buckets, and keeping the policy broad avoids
> permission-debugging during lessons. Do **not** copy this pattern to a
> production account — scope the role down to the specific services Terraform
> manages there.

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

## Fork & adapt

Course-specific values are **deliberately hardcoded** — the values files and
example manifests double as teaching references, and concrete hostnames beat
placeholders for that. (Templating layers like Helmfile/Kustomize overlays were
considered and rejected as abstraction this repo doesn't need.) To run the
platform under your own environment there are only a few knobs:

| Knob | Current value | Where to change it |
|------|---------------|--------------------|
| Base domain | `sctp-sandbox.com` | Hostnames in add-on values, `gateway-route.yaml` files, Kyverno host policies, and examples — find them all with `grep -rl sctp-sandbox.com` |
| Route53 zone | `Z00541411…` | `external_dns_hosted_zone_arns` in [terraform/eks-cluster/variables.tf](terraform/eks-cluster/variables.tf) (scopes the ExternalDNS IAM role) |
| Learner namespace pattern | `*-eks-activity` | [kyverno-policies/restrict-namespace-name-format.yaml](kyverno-policies/restrict-namespace-name-format.yaml) and [scripts/](scripts/) |
| AWS account | — | `ACCOUNT_ID` GitHub Actions **variable** |
| ACME registration email | — | `EMAIL_ADDRESS` GitHub Actions **secret** |

> Tip: lower your Route53 zone's SOA negative-cache TTL (default 900s → 60s) —
> first-time certificate issuance self-checks otherwise wait out cached
> NXDOMAIN responses for up to 15 minutes after ExternalDNS creates a record.

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on:
- Reporting bugs
- Suggesting enhancements
- Submitting pull requests
- Code style and structure

## License

This project is licensed under the terms specified in the [LICENSE](LICENSE) file.

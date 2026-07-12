# EKS Cluster

Terraform for the cluster itself: VPC, EKS control plane, node groups and the
IRSA roles. The comments in the `.tf` files carry the detail; this file is
just orientation.

## Usage

Pick a `.tfvars` file for the mode you want:

- `standard-wo-nodegroup.tfvars` - standard EKS without initial node groups
- `cilium-wo-nodegroup.tfvars` - Cilium mode, no node groups yet (install Cilium first)
- `cilium-with-nodegroup.tfvars` - Cilium mode with node groups (second apply, after Cilium is in)

Three boolean variables in `variables.tf` toggle optional IRSA resources, all
defaulting to `true`:

- `enable_external_dns` - IAM role for ExternalDNS with Route53
- `enable_loki_s3` - S3 buckets + IAM role for Loki
- `enable_ebs_csi_driver_role` - IAM role for the EBS CSI driver

Everything IRSA-related lives in `irsa.tf`.

## Introduction

This folder contains the required terraform files to create your AWS EKS cluster. 

## Usage

You may ```terraform apply``` the files as it is, however you may refer to the comments in the TF files for guidance as well.

You may also create the ExternalDNS resources (IAM Role for Service Account) & Loki Resources (Buckets & IAM Role for Service Account) based on the boolean flags below: 

```hcl
# Set to true if you're making use of ExternalDNS with Route53
variable "enable_external_dns" {
  type    = bool
  default = true
}

# Set to true if you're making use of Loki with a s3 backend
variable "enable_loki_s3" {
  type    = bool
  default = true
}

# Set to true if you're making use of a PersistentVolume with EBS CSI Driver Add-ons
variable "enable_ebs_csi_driver_role" {
  type    = bool
  default = true
}
```

All of the related IRSA resources are stored in ```irsa.tf``

Select one of the available `.tfvars` files based on your needs:

- `standard-wo-nodegroup.tfvars` - Standard EKS without initial node groups
- `cilium-wo-nodegroup.tfvars` - Cilium setup without node groups (install Cilium first)
- `cilium-with-nodegroup.tfvars` - Cilium setup with node groups (after Cilium is installed)

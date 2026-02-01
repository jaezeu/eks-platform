# Set to true if you're making use of ExternalDNS with Route53
variable "enable_external_dns" {
  description = "Set to true to create IAM role and policies for ExternalDNS with Route53"
  type        = bool
  default     = true
}

# Set to true if you're making use of Loki with a s3 backend
variable "enable_loki_s3" {
  description = "Set to true to create IAM role and policies for Loki with a s3 backend"
  type        = bool
  default     = true
}

# Set to true if you're making use of a PersistentVolume with EBS CSI Driver Add-ons
variable "enable_ebs_csi_driver_role" {
  description = "Set to true to create IAM role and policies for PersistentVolume with EBS CSI Driver Add-ons"
  type        = bool
  default     = true
}


########## Cilium Variables ###########
variable "deploy_node_groups" {
  description = "Set to true to deploy node groups"
  type        = bool
  default     = true
}

variable "enable_default_network_addons" {
  description = "Set to true for default network addons (kube-proxy and vpc-cni). For non-default network addons, set to false and use Cilium"
  type        = bool
  default     = true
}

variable "deploy_cluster_addons" {
  type        = bool
  description = "Deploy cluster addons (base and optionally default network addons)"
  default     = true
}

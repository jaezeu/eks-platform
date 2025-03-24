variable "region" {
  description = "The AWS region to deploy the EKS cluster"
  type        = string
  default     = "ap-southeast-1"
}
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


########## Cilium Variables ###########

variable "deploy_node_groups" {
  description = "Set to true to deploy node groups"
  type        = bool
  default     = true
}

variable "enable_default_network_addons" {
  description = "Set to true to enable default network addons"
  type        = bool
  default     = true
}

variable "bootstrap_self_managed_addons" {
  description = "Set to true to bootstrap self managed addons"
  type        = bool
  default     = true
}

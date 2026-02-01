locals {
  # Add more user groups if required to grant admin access since this is sandbox account
  merged_users  = concat(data.aws_iam_group.ce12.users, data.aws_iam_group.instructor.users)
  user_arn_list = [for obj in local.merged_users : obj["arn"]]

  # For default or non-default networking, the eks-pod-identity-agent is always deployed.
  # For default networking, all 4 addons are deployed as per the default variable values.
  # For non-default networking using Cilium, only the eks-pod-identity-agent is deployed first, while the coreDNS is only deployed after cilium is bootstrapped as part of the workflow.
  cluster_addons = merge(
    {
      "eks-pod-identity-agent" = {}
    },
    var.deploy_cluster_addons ? {
      "coredns" = {}
    } : {},
    var.enable_default_network_addons ? {
      "kube-proxy" = {}
      "vpc-cni"    = {}
    } : {}
  )
  name_prefix = var.enable_default_network_addons ? "shared" : "cilium" # So that the default cluster name remains the same as shared-eks-cluster.
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.15.1"

  bootstrap_self_managed_addons = true

  name               = "${local.name_prefix}-eks-cluster"
  kubernetes_version = "1.35"

  addons = local.cluster_addons

  endpoint_public_access                   = true
  enable_cluster_creator_admin_permissions = true

  enable_irsa = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = var.deploy_node_groups ? {
    "${local.name_prefix}_cluster_ng" = {
      ami_type       = "AL2023_ARM_64_STANDARD" # Update to AL2023_x86_64_STANDARD if using non-graviton instances
      instance_types = ["m6g.large"]
      min_size       = 3
      max_size       = 5
      desired_size   = 3
    }
  } : {}

  access_entries = {
    for arn in local.user_arn_list : arn => {
      principal_arn = arn
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.6.0"

  name                    = "${local.name_prefix}-eks-vpc"
  cidr                    = "172.31.0.0/16"
  azs                     = data.aws_availability_zones.available.names
  public_subnets          = ["172.31.101.0/24", "172.31.102.0/24"]
  private_subnets         = ["172.31.1.0/24", "172.31.2.0/24"]
  enable_nat_gateway      = true
  single_nat_gateway      = true
  map_public_ip_on_launch = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}



terraform {
  backend "s3" {
    bucket       = "sctp-core-tfstate"
    key          = "shared-eks-cluster-deployer-role.tfstate" #Update accordingly
    region       = "ap-southeast-1"
    use_lockfile = true # S3-native state locking so concurrent workflow runs cannot corrupt state
  }
}

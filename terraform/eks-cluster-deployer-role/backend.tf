terraform {
  backend "s3" {
    bucket       = "sctp-core-tfstate"
    key          = "shared-eks-cluster-deployer-role.tfstate" #Update accordingly
    region       = "ap-southeast-1"
  }
}

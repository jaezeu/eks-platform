terraform {
  backend "s3" {
    bucket       = "sctp-core-tfstate"
    key          = "shared-eks-cluster.tfstate"
    region       = "ap-southeast-1"
  }
}

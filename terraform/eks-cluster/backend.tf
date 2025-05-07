terraform {
  required_version = ">= 1.9.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.97.0"
    }
  }
  backend "s3" {
    bucket = "sctp-core-tfstate"
    key    = "shared-eks-cluster.tfstate"
    region = "ap-southeast-1"
  }
}

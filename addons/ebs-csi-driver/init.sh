#!/usr/bin/env bash

# 1. Add Helm repositories
helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver

# Update repos to ensure we have the latest charts
helm repo update

# 2. Install or upgrade ebs csi driver
# renovate: datasource=helm depName=aws-ebs-csi-driver registryUrl=https://kubernetes-sigs.github.io/aws-ebs-csi-driver
helm upgrade --install aws-ebs-csi-driver aws-ebs-csi-driver/aws-ebs-csi-driver --version 2.61.1 \
  --namespace kube-system \
  --values values.yaml

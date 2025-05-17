#!/usr/bin/env bash

# 1. Add Helm repositories
helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/shared-cluster-ebs-csidriver-role

# Update repos to ensure we have the latest charts
helm repo update

# 2. Install or upgrade ebs csi driver
helm upgrade --install aws-ebs-csi-driver aws-ebs-csi-driver/aws-ebs-csi-driver --version 2.43.0 \
  --namespace kube-system \
  --values values.yaml



#!/usr/bin/env bash

helm repo add argo https://argoproj.github.io/argo-helm

helm repo update

# renovate: datasource=helm depName=argo-cd registryUrl=https://argoproj.github.io/argo-helm
helm upgrade --install argocd argo/argo-cd --version 9.5.21 \
  --namespace argocd --create-namespace \
  --values values.yaml

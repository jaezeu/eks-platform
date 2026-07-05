#!/usr/bin/env bash

# renovate: datasource=helm depName=argo-cd registryUrl=https://argoproj.github.io/argo-helm
helm upgrade --install argocd argo-cd --repo https://argoproj.github.io/argo-helm --version 9.5.21 \
  --namespace argocd --create-namespace \
  --values values.yaml

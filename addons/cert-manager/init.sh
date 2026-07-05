#!/usr/bin/env bash

helm repo add jetstack https://charts.jetstack.io

helm repo update

# renovate: datasource=helm depName=cert-manager registryUrl=https://charts.jetstack.io
helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.20.2 \
  --values values.yaml

kubectl apply -f cluster-issuer.yaml


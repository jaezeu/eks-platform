#!/usr/bin/env bash

# renovate: datasource=helm depName=cert-manager registryUrl=https://charts.jetstack.io
helm upgrade --install cert-manager cert-manager --repo https://charts.jetstack.io \
  --namespace cert-manager \
  --create-namespace \
  --version v1.20.2 \
  --values values.yaml

kubectl apply -f cluster-issuer.yaml


#!/usr/bin/env bash

# renovate: datasource=helm depName=kube-prometheus-stack registryUrl=https://prometheus-community.github.io/helm-charts
helm upgrade --install kube-prometheus-stack kube-prometheus-stack --repo https://prometheus-community.github.io/helm-charts --version 86.2.2 \
  --create-namespace \
  --namespace monitoring \
  --values values.yaml



#!/usr/bin/env bash

# Values default to the standard (nginx Ingress) file. The Cilium workflow
# passes the Gateway API variant:  ./init.sh gateway-values.yaml
VALUES_FILE="${1:-values.yaml}"

# renovate: datasource=helm depName=kube-prometheus-stack registryUrl=https://prometheus-community.github.io/helm-charts
helm upgrade --install kube-prometheus-stack kube-prometheus-stack --repo https://prometheus-community.github.io/helm-charts --version 86.2.2 \
  --create-namespace \
  --namespace monitoring \
  --values "$VALUES_FILE"



#!/usr/bin/env bash

# 1. Add Helm repositories
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts

# Update repos to ensure we have the latest charts
helm repo update

# 2. Install or upgrade loki
# renovate: datasource=helm depName=loki registryUrl=https://grafana.github.io/helm-charts
helm upgrade --install loki grafana/loki --version 6.29.0 --values loki-values.yaml -n loki --create-namespace

# 3. Install or upgrade promtail
# renovate: datasource=helm depName=promtail registryUrl=https://grafana.github.io/helm-charts
helm upgrade --install promtail grafana/promtail --version 6.7.4 -n loki


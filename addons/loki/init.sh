#!/usr/bin/env bash

# renovate: datasource=helm depName=loki registryUrl=https://grafana.github.io/helm-charts
helm upgrade --install loki loki --repo https://grafana.github.io/helm-charts --version 6.29.0 --values loki-values.yaml -n loki --create-namespace

# renovate: datasource=helm depName=promtail registryUrl=https://grafana.github.io/helm-charts
helm upgrade --install promtail promtail --repo https://grafana.github.io/helm-charts --version 6.7.4 -n loki


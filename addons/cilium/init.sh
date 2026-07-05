#!/usr/bin/env bash
# Installs Cilium into kube-system. Expects values.yaml to already have
# ${CLUSTER_ENDPOINT} substituted (the workflow envsubst's it beforehand).

helm repo add cilium https://helm.cilium.io/

helm repo update

# renovate: datasource=helm depName=cilium registryUrl=https://helm.cilium.io/
helm upgrade --install cilium cilium/cilium --version 1.19.3 \
  --namespace kube-system \
  --values values.yaml

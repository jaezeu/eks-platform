#!/usr/bin/env bash

helm repo add cilium https://helm.cilium.io

helm repo update

helm upgrade --install tetragon cilium/tetragon \
  --namespace kube-system \
  --version v1.5.0 \
  --values values.yaml

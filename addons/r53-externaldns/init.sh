#!/usr/bin/env bash

# renovate: datasource=helm depName=external-dns registryUrl=https://kubernetes-sigs.github.io/external-dns/
helm upgrade --install external-dns external-dns --repo https://kubernetes-sigs.github.io/external-dns/ --version 1.21.1 \
  --namespace external-dns \
  --create-namespace \
  --values values.yaml

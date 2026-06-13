#!/usr/bin/env bash

helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/

helm repo update

helm upgrade --install external-dns external-dns/external-dns --version 1.21.1 \
  --namespace external-dns \
  --create-namespace \
  --values values.yaml

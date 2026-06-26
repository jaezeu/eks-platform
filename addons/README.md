# Cluster Add-ons

Helm-based add-ons installed on top of a provisioned EKS cluster. Each
directory is self-contained: a `values.yaml` (Helm configuration) and an
`init.sh` (adds the Helm repo and installs/upgrades the release). The
`init.sh` scripts are invoked by the bootstrap job in the
[cluster creation workflows](../.github/workflows), gated by per-add-on toggles.

## Add-ons at a glance

| Add-on | Namespace | Chart | Version | Purpose |
|--------|-----------|-------|---------|---------|
| [argocd](argocd/) | `argocd` | argo/argo-cd | 9.5.21 | GitOps continuous delivery |
| [cert-manager](cert-manager/) | `cert-manager` | jetstack/cert-manager | v1.20.2 | TLS certificates (Let's Encrypt) |
| [nginx-ingress](nginx-ingress/) | `ingress-nginx` | ingress-nginx/ingress-nginx | 4.15.1 | HTTP(S) ingress |
| [r53-externaldns](r53-externaldns/) | `external-dns` | external-dns/external-dns | 1.21.1 | Route 53 DNS automation |
| [kube-prometheus-stack](kube-prometheus-stack/) | `monitoring` | prometheus-community/kube-prometheus-stack | 86.2.2 | Prometheus, Grafana, Alertmanager |
| [loki](loki/) | `loki` | grafana/loki (+ promtail) | 6.29.0 | Log aggregation (S3 backend) |
| [ebs-csi-driver](ebs-csi-driver/) | `kube-system` | aws-ebs-csi-driver | 2.61.1 | EBS-backed persistent volumes |
| [cilium/tetragon](cilium/tetragon/) | `kube-system` | cilium/tetragon | v1.5.0 | eBPF runtime security (Cilium clusters) |

> **Cilium** itself (CNI, Hubble, Gateway API) is **not** installed from here — it
> is installed directly by the [Cilium cluster workflow](../.github/workflows/create-cilium-cluster.yml)
> before node groups join. See [cilium/](cilium/) for the Gateway API and SPIRE
> resources, and the [Cilium architecture diagram](../docs/images/cilium-architecture.png).

## Install order & dependencies

Order matters — several add-ons consume resources created by others:

1. **nginx-ingress** — provisions the load balancer other UIs are exposed through.
2. **external-dns** — needs its [IRSA role](../terraform/eks-cluster/irsa.tf) (Route 53); publishes records for Ingress hosts.
3. **cert-manager** — install the chart, then apply the [`ClusterIssuer`](cert-manager/cluster-issuer.yaml). Other add-ons reference it via `cert-manager.io/cluster-issuer` annotations.
4. **argocd**, **kube-prometheus-stack** — expose Ingress hosts (depend on 1–3 for DNS + TLS).
5. **loki** — needs its IRSA role and the two S3 buckets created by Terraform (`enable_loki_s3`).
6. **tetragon** — Cilium clusters only; ships ServiceMonitors scraped by Prometheus (install after monitoring).
7. **ebs-csi-driver** — needs its IRSA role; required before any workload requesting persistent volumes.

### IRSA-dependent add-ons

These rely on IAM Roles for Service Accounts created by
[`terraform/eks-cluster/irsa.tf`](../terraform/eks-cluster/irsa.tf):

| Add-on | Service account | AWS access |
|--------|-----------------|------------|
| external-dns | `external-dns` | Route 53 records |
| loki | `loki` | S3 (chunks + ruler buckets) |
| ebs-csi-driver | `ebs-csi-controller-sa` | EBS volume lifecycle |

## Manual install

Each add-on can be installed on its own once `kubectl`/`helm` are pointed at the
cluster. Some `init.sh` scripts expect environment variables (e.g.
`$EXTERNAL_DNS_ROLE_ARN`, `$CLUSTER_NAME`, `$REGION`) substituted into the
values file:

```bash
cd addons/<addon>
# review values.yaml, then:
./init.sh
```

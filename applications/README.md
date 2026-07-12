# Sample Applications

Example workloads used to exercise the platform: ingress, TLS, DNS,
persistent storage patterns and Prometheus scraping. Each directory has a
`values.yaml` and an `init.sh` that installs the Helm release into its own
namespace.

| App | Namespace | Chart | Notes |
|-----|-----------|-------|-------|
| [postgres](postgres/) | `postgres` | bitnami/postgresql 16.7.21 | Database `example-db` / user `example-user`. Metrics + ServiceMonitor enabled. |
| [wordpress](wordpress/) | `wordpress` | bitnami/wordpress 25.0.5 | Exposed via NGINX Ingress at `example-wordpress.sctp-sandbox.com` with Let's Encrypt TLS. |

> **Persistence is disabled** on both for demo use, so data is lost when pods
> restart. Enable `persistence` in the values files for durable storage
> (requires the [ebs-csi-driver](../addons/ebs-csi-driver/) add-on).

> WordPress uses its own embedded MariaDB, not the `postgres` deployment
> above; the two are independent examples.

## Prerequisites

- A running cluster with `kubectl`/`helm` configured
- For WordPress ingress + TLS: [nginx-ingress](../addons/nginx-ingress/),
  [cert-manager](../addons/cert-manager/) (+ ClusterIssuer) and
  [external-dns](../addons/r53-externaldns/)
- For ServiceMonitors to be scraped: [kube-prometheus-stack](../addons/kube-prometheus-stack/)

## Deploy

```bash
cd applications/<app>
./init.sh
```

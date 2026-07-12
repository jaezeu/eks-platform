# ArgoCD

Deploy after the ingress layer, ExternalDNS and cert-manager (with its
ClusterIssuer), since the values files expose the UI with TLS.

`init.sh` installs the chart. It defaults to the standard-cluster values
(nginx Ingress); the Cilium workflow passes the Gateway API variant:

```bash
./init.sh                       # standard: values.yaml (Ingress)
./init.sh gateway-values.yaml   # Cilium: gateway-route.yaml pairs with this
```

## First login

Username is `admin`; the initial password is generated at install time:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

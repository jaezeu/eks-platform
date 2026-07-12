# cert-manager

Deploy after the ingress layer and ExternalDNS, since the ClusterIssuers
solve ACME HTTP-01 challenges through them.

`init.sh` installs the chart and applies the ClusterIssuer. It defaults to the
standard-cluster files; the Cilium workflow passes the Gateway API variants:

```bash
./init.sh                                            # standard: values.yaml + cluster-issuer.yaml (nginx solver)
./init.sh gateway-values.yaml gateway-cluster-issuer.yaml   # Cilium: gatewayHTTPRoute solver
```

The issuer files contain an `${EMAIL}` placeholder for the ACME registration
email; the workflows envsubst it from the `EMAIL_ADDRESS` secret. For a
manual install, substitute it yourself before applying.

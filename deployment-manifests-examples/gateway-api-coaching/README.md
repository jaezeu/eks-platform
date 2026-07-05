# Gateway API coaching example (Cilium cluster)

The Gateway API version of [ingress-coaching](../ingress-coaching/): same echo
app, but exposed through the shared Cilium Gateway instead of an nginx Ingress.

## Who creates what

| Resource | Created by | Where |
|---|---|---|
| Gateway API CRDs, Cilium (controller), `shared-gateway` | Instructor (platform) | Cilium cluster workflow |
| cert-manager + `letsencrypt-gateway` ClusterIssuer, ExternalDNS | Instructor (platform) | Cilium cluster workflow |
| Deployment, Service, **ListenerSet**, **HTTPRoute** | Student | this folder |

## Ingress → Gateway API mapping

One `Ingress` object becomes two objects:

- **ListenerSet** ([listenerset.yaml](listenerset.yaml)) — "my hostname + TLS
  cert on the shared entrypoint". Replaces `spec.tls` + `ingressClassName`.
  Attaches your own HTTPS listener to `shared-gateway` without touching it
  (the Gateway allows this via `allowedListeners`).
- **HTTPRoute** ([httproute.yaml](httproute.yaml)) — "requests for my hostname
  go to my Service". Replaces `spec.rules`.

Same annotations as before, on new homes: `cert-manager.io/cluster-issuer`
moves to the ListenerSet, `external-dns.alpha.kubernetes.io/hostname` moves to
the HTTPRoute.

## Deploy

```bash
kubectl apply -f deployment.yaml -f service.yaml
kubectl apply -f listenerset.yaml -f httproute.yaml
```

Then watch it come up (cert issuance takes a minute or two):

```bash
kubectl get listenerset,httproute -n jaz-eks-activity   # Accepted/Programmed?
kubectl get certificate -n jaz-eks-activity             # Ready?
curl https://gateway-jaz-echoapp.sctp-sandbox.com       # Hello, jaz!
```

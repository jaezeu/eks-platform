# Deployment Manifest Examples

Plain Kubernetes manifests (no Helm) used as teaching references for common
patterns. Apply any directory with `kubectl apply -f <dir>/`.

| Example | Teaches |
|---------|---------|
| [eks-basic-deployment-with-service-account](eks-basic-deployment-with-service-account/) | A Deployment + Service wired to a ServiceAccount — the basis for IRSA (IAM Roles for Service Accounts). |
| [eks-service-types](eks-service-types/) | The Kubernetes Service types side by side: `ClusterIP`, `NodePort`, and `LoadBalancer`, with a sample app to back them. |
| [gateway-api-coaching](gateway-api-coaching/) | The Gateway API version of ingress-coaching: exposing the same app through the shared Cilium Gateway with a `ListenerSet` + `HTTPRoute` (Cilium cluster only). |
| [ingress-coaching](ingress-coaching/) | Exposing an app through an Ingress, plus a [netshoot](https://github.com/nicolaka/netshoot) pod for in-cluster network debugging (standard cluster). |
| [learner-prometheus](learner-prometheus/) | A standalone Prometheus deployment for hands-on monitoring exercises. |

## Usage

```bash
# apply a whole example
kubectl apply -f deployment-manifests-examples/eks-service-types/

# clean up
kubectl delete -f deployment-manifests-examples/eks-service-types/
```

> Hostnames and Service types in these manifests are examples — `LoadBalancer`
> services and Ingress hosts provision real AWS resources on a live cluster.

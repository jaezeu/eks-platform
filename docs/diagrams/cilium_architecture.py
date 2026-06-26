"""Deep-dive diagram of the Cilium stack as configured in this repo.

Covers the four pillars actually enabled in addons/cilium + the cilium
Helm install in create-cilium-cluster.yml:
  1. Data plane   - eBPF, kube-proxy replacement, ENI IPAM, native routing
  2. Observability- Hubble agent -> Relay -> UI, metrics to Prometheus
  3. Runtime sec  - Tetragon DaemonSet + Operator -> ServiceMonitor
  4. Identity/mTLS- SPIRE server/agent for Cilium mutual authentication
  Plus Gateway API ingress: GatewayClass cilium -> shared-gateway -> HTTPRoute.

Regenerate:  python3 cilium_architecture.py  ->  ../images/cilium-architecture.png
"""

from diagrams import Cluster, Diagram, Edge
from diagrams.aws.network import VPCElasticNetworkInterface as ElasticNetworkInterface, VPC
from diagrams.k8s.compute import Pod, DaemonSet, Deployment, StatefulSet
from diagrams.k8s.network import Service, Ingress
from diagrams.k8s.others import CRD
from diagrams.onprem.monitoring import Prometheus, Grafana
from diagrams.onprem.client import User
from diagrams.custom import Custom

graph_attr = {
    "fontsize": "22",
    "labelloc": "t",
    "bgcolor": "white",
    "pad": "0.7",
    "nodesep": "0.45",
    "ranksep": "1.0",
}
import os
_ICON_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "icons")
ICON = lambda n: os.path.join(_ICON_DIR, f"{n}.png")

with Diagram(
    "Cilium Stack — Data Plane, Hubble, Tetragon, SPIRE, Gateway API",
    filename="../images/cilium-architecture",
    show=False,
    direction="LR",
    graph_attr=graph_attr,
):
    user = User("external\nclient")

    with Cluster("AWS VPC  (native routing  ipv4NativeRoutingCIDR 0.0.0.0/0)"):
        eni = ElasticNetworkInterface("ENI IPAM\nprefix delegation\n(ipam.mode=eni)")

        with Cluster("EKS Cluster — kube-proxy-free (kubeProxyReplacement=true)"):

            # ---------- Data plane on each node ----------
            with Cluster("Worker node  (eBPF datapath)"):
                agent = Custom("Cilium agent\n(DaemonSet)", ICON("cilium"))
                ebpf = Custom("eBPF / BPF maps\nservice LB + masq", ICON("cilium"))
                with Cluster("workload pods"):
                    pods = [Pod("pod"), Pod("pod")]
                tetra = Custom("Tetragon\n(DaemonSet)", ICON("tetragon"))
                spire_agent = Custom("SPIRE agent", ICON("spiffe"))

            cil_operator = Custom("Cilium Operator", ICON("cilium"))
            tetra_op = Custom("Tetragon Operator", ICON("tetragon"))

            # ---------- Identity / mTLS ----------
            with Cluster("Mutual authentication (SPIFFE)"):
                spire_server = Custom("SPIRE server\n(StatefulSet)", ICON("spiffe"))

            # ---------- Observability: Hubble ----------
            with Cluster("Hubble observability"):
                hubble_relay = Custom("Hubble Relay", ICON("hubble"))
                hubble_ui = Custom("Hubble UI", ICON("hubble"))

            # ---------- Ingress: Gateway API ----------
            with Cluster("Gateway API  (gatewayAPI.enabled, class=cilium)"):
                gwclass = CRD("GatewayClass\ncilium")
                gateway = Ingress("shared-gateway\nns: gateway\n:80 / :443 TLS")
                httproute = CRD("HTTPRoute\nfrontend-route\nns: otel-demo")
                backend = Service("frontend-proxy\n:8080")

    # ---------- monitoring ----------
    with Cluster("ns: monitoring"):
        prom = Prometheus("Prometheus")
        graf = Grafana("Grafana")

    # ===== data plane wiring =====
    eni >> Edge(label="ENI per node\n(prefix deleg.)") >> agent
    agent >> ebpf
    ebpf >> Edge(label="eBPF service LB\n(no iptables/kube-proxy)") >> pods
    cil_operator >> Edge(style="dashed") >> agent

    # ===== identity / mTLS =====
    spire_server >> Edge(color="brown", label="SPIFFE SVIDs") >> spire_agent
    spire_agent >> Edge(color="brown", style="dashed", label="mTLS identity") >> agent

    # ===== Hubble flow =====
    agent >> Edge(color="darkgreen", label="flow data") >> hubble_relay
    hubble_relay >> hubble_ui
    agent >> Edge(style="dotted", color="gray40", label="hubble metrics\n{dns,drop,tcp,flow,http}") >> prom

    # ===== Tetragon =====
    tetra_op >> Edge(style="dashed") >> tetra
    tetra >> Edge(style="dotted", color="gray40", label="ServiceMonitor") >> prom
    prom >> Edge(color="orange") >> graf

    # ===== Gateway API ingress path =====
    user >> Edge(color="darkblue", label="HTTPS\ngateway-frontend.sctp-sandbox.com") >> gateway
    gwclass >> Edge(style="dashed") >> gateway
    gateway >> Edge(color="darkblue") >> httproute
    httproute >> Edge(color="darkblue", label="PathPrefix /") >> backend
    backend >> pods

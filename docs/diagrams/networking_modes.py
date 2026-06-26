"""Standard vs Cilium networking comparison (data-plane focused).

  Standard : AWS VPC CNI (ENI per pod) + kube-proxy (iptables) + CoreDNS
  Cilium   : Cilium CNI, ENI IPAM + prefix delegation, kube-proxy-free eBPF,
             native routing; adds Hubble, Tetragon, SPIRE, Gateway API
             (shown in detail in cilium-architecture.png).

Regenerate:  python3 networking_modes.py  ->  ../images/networking-modes.png
"""

from diagrams import Cluster, Diagram, Edge
from diagrams.aws.network import VPC, VPCElasticNetworkInterface as ENI
from diagrams.k8s.compute import Pod, DaemonSet
from diagrams.k8s.network import Service
from diagrams.k8s.controlplane import KubeProxy
from diagrams.k8s.infra import Node
from diagrams.onprem.dns import Coredns
from diagrams.onprem.client import Users
from diagrams.custom import Custom

graph_attr = {
    "fontsize": "22",
    "labelloc": "t",
    "bgcolor": "white",
    "pad": "0.7",
    "ranksep": "0.9",
}
import os
_ICON_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "icons")
ICON = lambda n: os.path.join(_ICON_DIR, f"{n}.png")

with Diagram(
    "Networking Modes — Standard (VPC CNI) vs Cilium (eBPF)",
    filename="../images/networking-modes",
    show=False,
    direction="TB",
    graph_attr=graph_attr,
):
    clients = Users("cluster traffic")

    with Cluster("STANDARD EKS   —   AWS VPC CNI + kube-proxy   (enable_default_networking=true)"):
        s_eni = ENI("VPC CNI\nENI per pod")
        s_dns = Coredns("CoreDNS")
        with Cluster("Worker node"):
            s_node = Node("kubelet")
            s_kp = KubeProxy("kube-proxy\niptables / netfilter")
            s_pods = [Pod("pod"), Pod("pod")]
        s_svc = Service("Service\n(iptables NAT)")

        s_eni >> s_node >> s_pods
        s_kp >> Edge(label="iptables rules") >> s_svc >> s_pods
        s_dns >> Edge(style="dotted") >> s_pods

    with Cluster("CILIUM EKS   —   Cilium CNI, ENI mode, kube-proxy-free   (enable_default_networking=false)"):
        c_eni = ENI("Cilium ENI IPAM\nprefix delegation\nnative routing")
        c_dns = Coredns("CoreDNS")
        with Cluster("Worker node"):
            c_node = Node("kubelet")
            c_agent = Custom("Cilium agent\neBPF datapath\n(replaces kube-proxy)", ICON("cilium"))
            c_pods = [Pod("pod"), Pod("pod")]
        c_svc = Service("Service\n(eBPF maps)")
        with Cluster("added by Cilium"):
            extras = [
                Custom("Hubble\nflow visibility", ICON("hubble")),
                Custom("Tetragon\nruntime security", ICON("tetragon")),
                Custom("SPIRE\nmTLS identity", ICON("spiffe")),
            ]

        c_eni >> c_node >> c_pods
        c_agent >> Edge(label="eBPF service LB", color="darkgreen") >> c_svc >> c_pods
        c_dns >> Edge(style="dotted") >> c_pods
        c_agent >> Edge(style="dotted", color="gray40") >> extras

    clients >> Edge(style="dashed") >> s_node
    clients >> Edge(style="dashed") >> c_node

# Architecture Diagrams (as code)

The diagrams in the project documentation are generated with
[`diagrams`](https://diagrams.mingrammer.com/) (Diagram as Code), so they live
in version control and can be regenerated when the architecture changes.

| Script | Output | Shows |
|--------|--------|-------|
| `platform_overview.py` | `../images/platform-overview.png` | Full platform: VPC/subnets, EKS control plane + managed add-ons, ARM64 node group, every add-on by namespace, Kyverno admission, IRSA → AWS |
| `networking_modes.py` | `../images/networking-modes.png` | Standard (VPC CNI + kube-proxy) vs Cilium (eBPF, kube-proxy-free), incl. Cilium's Hubble/Tetragon/SPIRE extras |
| `cilium_architecture.py` | `../images/cilium-architecture.png` | Cilium deep dive: eBPF data plane + ENI IPAM, Hubble (agent→relay→UI), Tetragon, SPIRE mTLS, Gateway API ingress |
| `bootstrap_flow.py` | `../images/bootstrap-flow.png` | Both workflows side by side: standard single-apply vs Cilium split-apply (CNI before nodes) + add-on order |

The `icons/` directory holds project logos (Cilium, Hubble, SPIFFE/SPIRE,
cert-manager, Kyverno, ExternalDNS) used as `Custom` nodes, since the
`diagrams` library does not ship these. They are pulled from the CNCF/project
artwork repos.

## Prerequisites

- **Graphviz** (provides the `dot` binary):
  ```bash
  sudo apt install graphviz        # Debian/Ubuntu
  brew install graphviz            # macOS
  ```
- **Python packages**:
  ```bash
  pip install -r requirements.txt
  ```

## Regenerate

```bash
cd docs/diagrams
python3 platform_overview.py
python3 networking_modes.py
python3 cilium_architecture.py
python3 bootstrap_flow.py
```

Each script writes its PNG into `docs/images/`.

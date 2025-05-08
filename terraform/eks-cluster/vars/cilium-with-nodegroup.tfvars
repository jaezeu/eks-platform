# These are the variables to be set before Cilium after bootstrapped.
# This is so that nodes & CoreDNS can be added to the cluster after Cilium is bootstrapped to be managed by Cilium.
deploy_node_groups            = true
enable_default_network_addons = false
deploy_cluster_addons         = true
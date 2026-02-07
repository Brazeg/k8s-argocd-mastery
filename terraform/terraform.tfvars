# =============================================================================
# Lab Configuration
# =============================================================================
# Customize these values for your setup

cluster_name = "k8s-lab"

# Port mappings (host_port:container_port)
# These ports will be accessible on localhost
node_ports = [
  { container_port = 30080, host_port = 30080 },  # ArgoCD
  { container_port = 30081, host_port = 30081 },  # Grafana
  { container_port = 30082, host_port = 30082 },  # Demo app
  { container_port = 30083, host_port = 30083 },  # Additional
  { container_port = 30084, host_port = 30084 },  # Additional
  { container_port = 30090, host_port = 30090 },
]

argocd_node_port = 30080

# Namespaces to pre-create
lab_namespaces = [
  "monitoring",  # For LGTM stack
  "apps",        # For demo applications
  "dev",         # Development environment
  "staging",     # Staging environment
]

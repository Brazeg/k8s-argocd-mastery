# =============================================================================
# Variables
# =============================================================================

variable "cluster_name" {
  description = "Name of the Kind cluster"
  type        = string
  default     = "k8s-lab"
}

variable "node_ports" {
  description = "Port mappings from host to cluster"
  type = list(object({
    container_port = number
    host_port      = number
    protocol       = optional(string, "TCP")
  }))
  default = [
    { container_port = 30080, host_port = 30080 },  # ArgoCD
    { container_port = 30081, host_port = 30081 },  # Grafana
    { container_port = 30082, host_port = 30082 },  # Demo app
    { container_port = 30083, host_port = 30083 },  # Additional
    { container_port = 30084, host_port = 30084 },  # Additional
  ]
}

variable "argocd_node_port" {
  description = "NodePort for ArgoCD server"
  type        = number
  default     = 30080
}

variable "lab_namespaces" {
  description = "Namespaces to create for the learning lab"
  type        = list(string)
  default     = ["monitoring", "apps", "dev", "staging"]
}

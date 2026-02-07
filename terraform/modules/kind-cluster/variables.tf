variable "cluster_name" {
  description = "Name of the Kind cluster"
  type        = string
  default     = "k8s-lab"
}

variable "node_ports" {
  description = "List of port mappings"
  type = list(object({
    container_port = number
    host_port      = number
    protocol       = optional(string, "TCP")
  }))
  default = []
}

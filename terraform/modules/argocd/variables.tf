variable "namespace" {
  description = "Namespace for ArgoCD"
  type        = string
  default     = "argocd"
}

variable "argocd_version" {
  description = "ArgoCD Helm chart version"
  type        = string
  default     = "5.51.6"  # Maps to ArgoCD v2.10.x
}

variable "node_port" {
  description = "NodePort for ArgoCD server"
  type        = number
  default     = 30080
}

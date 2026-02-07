output "namespace" {
  description = "ArgoCD namespace"
  value       = kubernetes_namespace.argocd.metadata[0].name
}

output "release_name" {
  description = "Helm release name"
  value       = helm_release.argocd.name
}

output "argocd_server_service" {
  description = "ArgoCD server service name"
  value       = "${helm_release.argocd.name}-server"
}

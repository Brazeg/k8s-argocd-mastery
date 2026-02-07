# =============================================================================
# Outputs
# =============================================================================

output "cluster_name" {
  description = "Name of the Kind cluster"
  value       = module.kind_cluster.cluster_name
}

output "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  value       = module.kind_cluster.kubeconfig_path
}

output "argocd_url" {
  description = "URL to access ArgoCD"
  value       = "http://localhost:${var.argocd_node_port}"
}

output "argocd_initial_password_command" {
  description = "Command to get ArgoCD initial admin password"
  value       = "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d && echo"
}

output "grafana_url" {
  description = "URL to access Grafana (after LGTM stack is deployed)"
  value       = "http://localhost:30081"
}

output "namespaces_created" {
  description = "List of namespaces created"
  value       = [for ns in kubernetes_namespace.lab_namespaces : ns.metadata[0].name]
}

output "next_steps" {
  description = "What to do next"
  value       = <<-EOT
    
    ╔════════════════════════════════════════════════════════════════╗
    ║  ✓ Infrastructure Ready!                                       ║
    ╠════════════════════════════════════════════════════════════════╣
    ║                                                                 ║
    ║  ArgoCD UI: http://localhost:${var.argocd_node_port}                         ║
    ║  Username:  admin                                               ║
    ║  Password:  Run the command above                               ║
    ║                                                                 ║
    ║  Next: Start learning!                                          ║
    ║    cd ../01-kubernetes-basics                                   ║
    ║    cat README.md                                                ║
    ║                                                                 ║
    ╚════════════════════════════════════════════════════════════════╝
  EOT
}

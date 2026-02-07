output "cluster_name" {
  description = "The name of the cluster"
  value       = kind_cluster.this.name
}

output "endpoint" {
  description = "Kubernetes API endpoint"
  value       = kind_cluster.this.endpoint
}

output "kubeconfig" {
  description = "Kubeconfig content"
  value       = kind_cluster.this.kubeconfig
  sensitive   = true
}

output "kubeconfig_path" {
  description = "Path to kubeconfig file"
  value       = local_file.kubeconfig.filename
}

output "cluster_ca_certificate" {
  description = "Cluster CA certificate"
  value       = kind_cluster.this.cluster_ca_certificate
  sensitive   = true
}

output "client_certificate" {
  description = "Client certificate"
  value       = kind_cluster.this.client_certificate
  sensitive   = true
}

output "client_key" {
  description = "Client key"
  value       = kind_cluster.this.client_key
  sensitive   = true
}

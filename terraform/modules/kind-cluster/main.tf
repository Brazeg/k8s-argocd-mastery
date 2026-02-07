# =============================================================================
# Kind Cluster Module
# =============================================================================
# Creates a Kubernetes cluster using Kind (Kubernetes in Docker)
# =============================================================================

terraform {
  required_providers {
    kind = {
      source  = "tehcyx/kind"
      version = "~> 0.4"
    }
  }
}

resource "kind_cluster" "this" {
  name           = var.cluster_name
  wait_for_ready = true

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"

      # Map NodePorts to host ports
      dynamic "extra_port_mappings" {
        for_each = var.node_ports
        content {
          container_port = extra_port_mappings.value.container_port
          host_port      = extra_port_mappings.value.host_port
          protocol       = extra_port_mappings.value.protocol
        }
      }

      # Enable kubectl access
      kubeadm_config_patches = [
        <<-PATCH
        kind: InitConfiguration
        nodeRegistration:
          kubeletExtraArgs:
            node-labels: "ingress-ready=true"
        PATCH
      ]
    }
  }
}

# Export kubeconfig to a file for other tools
resource "local_file" "kubeconfig" {
  content  = kind_cluster.this.kubeconfig
  filename = "${path.root}/kubeconfig"

  provisioner "local-exec" {
    command = "chmod 600 ${self.filename}"
  }
}

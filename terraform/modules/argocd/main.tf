# =============================================================================
# ArgoCD Module
# =============================================================================
# Installs ArgoCD using Helm
# =============================================================================

terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
  }
}

# Create ArgoCD namespace
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.namespace
    labels = {
      "managed-by" = "terraform"
    }
  }
}

# Install ArgoCD using Helm
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_version
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  # Wait for installation to complete
  wait          = true
  wait_for_jobs = true
  timeout       = 600

  # ArgoCD configuration
  values = [
    yamlencode({
      # Server configuration
      server = {
        service = {
          type = "NodePort"
          nodePortHttp = var.node_port
          nodePortHttps = var.node_port
        }
        # Disable TLS for local development (simpler access)
        extraArgs = ["--insecure"]
      }

      # Disable DEX (not needed for local lab)
      dex = {
        enabled = false
      }

      # Notifications (disabled for simplicity)
      notifications = {
        enabled = false
      }

      # ApplicationSet controller (needed for advanced modules)
      applicationSet = {
        enabled = true
      }

      # Resource limits for local development
      controller = {
        resources = {
          limits = {
            cpu    = "500m"
            memory = "512Mi"
          }
          requests = {
            cpu    = "100m"
            memory = "256Mi"
          }
        }
      }

      repoServer = {
        resources = {
          limits = {
            cpu    = "500m"
            memory = "512Mi"
          }
          requests = {
            cpu    = "100m"
            memory = "256Mi"
          }
        }
      }

      redis = {
        resources = {
          limits = {
            cpu    = "200m"
            memory = "128Mi"
          }
          requests = {
            cpu    = "50m"
            memory = "64Mi"
          }
        }
      }
    })
  ]
}

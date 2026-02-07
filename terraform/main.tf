# =============================================================================
# Kubernetes + ArgoCD Lab Infrastructure
# =============================================================================
# This Terraform configuration creates:
# 1. A Kind (Kubernetes in Docker) cluster
# 2. ArgoCD installation
# 3. Namespaces for the lab
# =============================================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    kind = {
      source  = "tehcyx/kind"
      version = "~> 0.4"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
   # Use this provider for situations where you wish if terrafrom could just run a shell command to do something, e.g running specif kubectl commands or going to sleep until a resource is fully ready 
   # null = {
   #   source  = "hashicorp/null"
   #   version = "~> 3.2"
   # }
  }
}

# =============================================================================
# Kind Cluster
# =============================================================================
module "kind_cluster" {
  source = "./modules/kind-cluster"

  cluster_name = var.cluster_name
  node_ports   = var.node_ports
}

# =============================================================================
# Kubernetes Provider Configuration
# =============================================================================
provider "kubernetes" {
  host                   = module.kind_cluster.endpoint
  cluster_ca_certificate = module.kind_cluster.cluster_ca_certificate
  client_certificate     = module.kind_cluster.client_certificate
  client_key             = module.kind_cluster.client_key
}

provider "helm" {
  kubernetes {
    host                   = module.kind_cluster.endpoint
    cluster_ca_certificate = module.kind_cluster.cluster_ca_certificate
    client_certificate     = module.kind_cluster.client_certificate
    client_key             = module.kind_cluster.client_key
  }
}

# =============================================================================
# ArgoCD
# =============================================================================
module "argocd" {
  source = "./modules/argocd"

  namespace    = "argocd"
  node_port    = var.argocd_node_port
  
  depends_on = [module.kind_cluster]
}

# =============================================================================
# Lab Namespaces
# =============================================================================
resource "kubernetes_namespace" "lab_namespaces" {
  for_each = toset(var.lab_namespaces)

  metadata {
    name = each.value
    labels = {
      "managed-by" = "terraform"
      "purpose"    = "learning-lab"
    }
  }

  depends_on = [module.kind_cluster]
}

# Terraform Infrastructure

This directory contains the Infrastructure as Code (IaC) for the learning lab.

## What Terraform Creates

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    INFRASTRUCTURE MANAGED BY TERRAFORM                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                        Kind Cluster                                  │   │
│  │                                                                      │   │
│  │  • Kubernetes control plane                                          │   │
│  │  • NodePort mappings (30080-30084)                                   │   │
│  │  • kubeconfig exported                                               │   │
│  │                                                                      │   │
│  │  ┌────────────────────────────────────────────────────────────────┐  │   │
│  │  │                      ArgoCD (Helm)                             │  │   │
│  │  │                                                                │  │   │
│  │  │  • argocd-server (NodePort 30080)                              │  │   │
│  │  │  • argocd-repo-server                                          │  │   │
│  │  │  • argocd-application-controller                               │  │   │
│  │  │  • argocd-applicationset-controller                            │  │   │
│  │  │  • argocd-redis                                                │  │   │
│  │  │                                                                │  │   │
│  │  └────────────────────────────────────────────────────────────────┘  │   │
│  │                                                                      │   │
│  │  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌─────────────┐  │   │
│  │  │ NS: monitoring│ │ NS: apps     │ │ NS: dev      │ │ NS: staging   │   │
│  │  └──────────────┘ └──────────────┘ └──────────────┘ └─────────────┘  │   │
│  │                                                                      │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘


SEPARATION OF CONCERNS
══════════════════════

Terraform manages:               ArgoCD manages (via GitOps):
────────────────────             ────────────────────────────
• Cluster creation               • Application deployments
• ArgoCD installation            • ConfigMaps, Secrets
• Namespace creation             • Services, Ingresses
• Base infrastructure            • Everything in apps/

This is the recommended pattern for production!
```

## Usage

### Initialize (First Time Only)

```bash
cd terraform
terraform init
```

### Create Infrastructure

```bash
terraform plan      # Preview changes
terraform apply     # Create resources (type 'yes' to confirm)
```

### Access ArgoCD

After `terraform apply` completes:

```bash
# URL shown in output
# http://localhost:30080

# Get password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 -d && echo

# Login: admin / <password from above>
```

### Destroy Infrastructure

```bash
terraform destroy   # Removes everything (type 'yes' to confirm)
```

## File Structure

```
terraform/
├── main.tf              # Main configuration (uses modules)
├── variables.tf         # Input variables
├── outputs.tf           # Output values
├── terraform.tfvars     # Your configuration values
│
└── modules/
    ├── kind-cluster/    # Kind cluster creation
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    └── argocd/          # ArgoCD installation
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## Customization

Edit `terraform.tfvars` to customize:

```hcl
# Change cluster name
cluster_name = "my-cluster"

# Add more namespaces
lab_namespaces = ["monitoring", "apps", "dev", "staging", "prod"]

# Change ArgoCD port
argocd_node_port = 8080
```

## Module Details

### kind-cluster

Creates a local Kubernetes cluster using Kind.

**Inputs:**
| Name | Description | Default |
|------|-------------|---------|
| cluster_name | Cluster name | k8s-lab |
| node_ports | Port mappings | 30080-30084 |

**Outputs:**
| Name | Description |
|------|-------------|
| endpoint | Kubernetes API URL |
| kubeconfig_path | Path to kubeconfig file |

### argocd

Installs ArgoCD via Helm with sensible defaults for learning.

**Inputs:**
| Name | Description | Default |
|------|-------------|---------|
| namespace | ArgoCD namespace | argocd |
| argocd_version | Helm chart version | 5.51.6 |
| node_port | Server NodePort | 30080 |

## Terraform State

State is stored locally in `terraform.tfstate`. For a real project, use remote state:

```hcl
# Example: Azure Storage backend
terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstate12345"
    container_name       = "tfstate"
    key                  = "k8s-lab.tfstate"
  }
}
```

## Troubleshooting

### "Kind cluster already exists"
```bash
kind delete cluster --name k8s-lab
terraform apply
```

### "Cannot connect to Kubernetes"
```bash
export KUBECONFIG=$(pwd)/kubeconfig
kubectl get nodes
```

### "ArgoCD pods not starting"
```bash
kubectl get pods -n argocd
kubectl describe pod -n argocd <pod-name>
```

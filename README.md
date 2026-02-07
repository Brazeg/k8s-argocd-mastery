<img src="img/Lab image.png" alt="Lab Image" title="Lab Image" width="800"/>

# Kubernetes + ArgoCD Mastery Lab

A hands-on learning path from beginner to advanced, featuring **Infrastructure as Code** with Terraform and **GitOps** with ArgoCD.

---

## What You'll Learn

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         SKILLS COVERED                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  INFRASTRUCTURE (Terraform)          APPLICATIONS (Kubernetes + ArgoCD)      │
│  ──────────────────────────          ─────────────────────────────────       │
│  • Terraform basics                  • Pods, Deployments, Services           │
│  • Modules and state                 • ConfigMaps, Secrets, Volumes          │
│  • Provider configuration            • RBAC, NetworkPolicies                 │
│  • Kind cluster creation             • ArgoCD fundamentals                   │
│  • Helm provider                     • GitOps workflows                      │
│                                      • Helm & Kustomize                      │
│                                      • ApplicationSets                       │
│                                      • Observability (LGTM)                  │
│                                                                              │
│  This separation mirrors real-world DevOps:                                  │
│  Terraform → Infrastructure    |    ArgoCD → Applications                    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Quick Start

```bash
# 1. Setup tools (with asdf)
./scripts/setup.sh
source ~/.asdf/asdf.sh

# 2. Create infrastructure with Terraform
./scripts/create-cluster-terraform.sh

# 3. Set kubeconfig
export KUBECONFIG=$(pwd)/terraform/kubeconfig

# 4. Start learning!
cd 01-kubernetes-basics && cat README.md
```

See [QUICKSTART.md](QUICKSTART.md) for detailed instructions.

---

## Project Structure

```
k8s-argocd-mastery/
│
├── .tool-versions              ← asdf tool versions (portable!)
│
├── terraform/                  ← INFRASTRUCTURE AS CODE
│   ├── main.tf                 ← Main configuration
│   ├── variables.tf            ← Input variables
│   ├── outputs.tf              ← Output values
│   ├── terraform.tfvars        ← Your settings
│   └── modules/
│       ├── kind-cluster/       ← Cluster creation
│       └── argocd/             ← ArgoCD installation
│
├── scripts/
│   ├── setup.sh                ← Install asdf + tools
│   ├── setup-manual.sh         ← Install without asdf
│   ├── create-cluster-terraform.sh  ← Create with Terraform ⭐
│   ├── create-cluster.sh       ← Create with bash (simple)
│   ├── destroy-cluster-terraform.sh ← Destroy with Terraform
│   └── delete-cluster.sh       ← Delete with bash
│
├── 01-kubernetes-basics/       ← Pods, Deployments, Services
├── 02-kubernetes-intermediate/ ← ConfigMaps, Secrets, Volumes
├── 03-kubernetes-advanced/     ← RBAC, NetworkPolicies, HPA
├── 04-argocd-basics/           ← GitOps fundamentals
├── 05-argocd-intermediate/     ← Helm, Kustomize, Sync Waves
├── 06-argocd-advanced/         ← ApplicationSets, Multi-cluster
├── 07-observability/           ← Grafana LGTM Stack
├── 08-production-patterns/     ← Real-world patterns
│
└── apps/                       ← Demo applications
    ├── demo-app/               ← Simple Helm chart
    └── tns/                    ← Observability demo
```

---

## Learning Path

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         LEARNING JOURNEY                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  WEEK 0: SETUP                                                               │
│  ═════════════                                                               │
│  • Install tools with asdf                                                   │
│  • Create cluster with Terraform ← Learn IaC basics here!                    │
│  • Explore terraform/ directory                                              │
│                                                                              │
│  PHASE 1: KUBERNETES FUNDAMENTALS (Weeks 1-2)                                │
│  ═════════════════════════════════════════════                               │
│  Module 01: Basics        - Pods, Services, Deployments                      │
│  Module 02: Intermediate  - ConfigMaps, Secrets, Volumes, Probes             │
│  Module 03: Advanced      - RBAC, NetworkPolicies, HPA                       │
│                                                                              │
│  PHASE 2: ARGOCD & GITOPS (Weeks 3-4)                                        │
│  ════════════════════════════════════                                        │
│  Module 04: Basics        - Install, Applications, Sync                      │
│  Module 05: Intermediate  - Helm, Kustomize, Sync Waves                      │
│  Module 06: Advanced      - ApplicationSets, Multi-cluster                   │
│                                                                              │
│  PHASE 3: REAL-WORLD SKILLS (Week 5)                                         │
│  ═══════════════════════════════════                                         │
│  Module 07: Observability - Grafana LGTM Stack                               │
│  Module 08: Production    - Multi-env, Secrets, Policies                     │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Tool Versions

Managed by asdf via `.tool-versions`:

| Tool | Version | Purpose |
|------|---------|---------|
| kubectl | 1.29.0 | Kubernetes CLI |
| kind | 0.20.0 | Local Kubernetes clusters |
| helm | 3.14.0 | Package manager |
| terraform | 1.7.0 | Infrastructure as Code |
| argocd | 2.10.0 | GitOps CLI |
| k9s | 0.31.7 | Terminal UI for K8s |
| yq | 4.40.5 | YAML processor |

---

## Time Estimates

| Module | Duration | Difficulty |
|--------|----------|------------|
| Setup + Terraform | 1 hour | ⭐ Beginner |
| 01 K8s Basics | 3-4 hours | ⭐ Beginner |
| 02 K8s Intermediate | 4-5 hours | ⭐⭐ Intermediate |
| 03 K8s Advanced | 4-5 hours | ⭐⭐⭐ Advanced |
| 04 ArgoCD Basics | 2-3 hours | ⭐ Beginner |
| 05 ArgoCD Intermediate | 3-4 hours | ⭐⭐ Intermediate |
| 06 ArgoCD Advanced | 4-5 hours | ⭐⭐⭐ Advanced |
| 07 Observability | 3-4 hours | ⭐⭐ Intermediate |
| 08 Production | 3-4 hours | ⭐⭐⭐ Advanced |

**Total: ~30-35 hours of hands-on learning**

---

## Prerequisites

- Windows with WSL2 (Ubuntu recommended)
- Docker Desktop with WSL2 integration enabled
- 60 GB disk space (uses ~15 GB)
- Internet connection
- GitHub account (for GitOps exercises)

---

## Terraform Highlights

The `terraform/` directory demonstrates:

```hcl
# Modular structure
module "kind_cluster" {
  source = "./modules/kind-cluster"
  cluster_name = var.cluster_name
}

module "argocd" {
  source = "./modules/argocd"
  depends_on = [module.kind_cluster]
}

# Multiple providers
provider "kubernetes" { ... }
provider "helm" { ... }
```

This teaches you:
- ✓ Terraform modules and reusability
- ✓ Provider configuration
- ✓ Dependency management
- ✓ State management
- ✓ The Terraform → Kubernetes → Helm workflow

---

## Next Steps After Completing the Lab

1. **Deploy to real cloud** - Modify terraform/modules for AKS/EKS/GKE
2. **Add remote state** - Use Azure Storage or S3 for terraform state
3. **Multi-cluster ArgoCD** - Manage multiple environments
4. **External Secrets** - Integrate with Azure Key Vault / AWS Secrets Manager
5. **Build your own IDP** - Create an Internal Developer Platform

---

**Happy Learning!** 🚀

# Quick Start Guide

Get up and running in 10 minutes!

## Prerequisites Check

```bash
# Verify Docker is running
docker info

# Verify asdf tools are installed
asdf current
```

---

## Two Ways to Create the Lab

### Option A: Terraform (Recommended) 🏆

Uses Infrastructure as Code - the professional way.

```bash
# 1. Create infrastructure
./scripts/create-cluster-terraform.sh

# 2. Set kubeconfig (shown in output, or run this)
export KUBECONFIG=$(pwd)/terraform/kubeconfig

# 3. Verify
kubectl get nodes
kubectl get pods -n argocd
```

### Option B: Bash Scripts (Simple)

Quick and simple, but less learning value.

```bash
# 1. Create cluster
./scripts/create-cluster.sh

# 2. Verify
kubectl get nodes
```

---

## Which Option Should You Choose?

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    TERRAFORM vs BASH SCRIPTS                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  TERRAFORM (Option A)                 BASH (Option B)                        │
│  ────────────────────                 ────────────────                       │
│  ✓ Learn IaC patterns                 ✓ Quick to run                         │
│  ✓ See state management               ✓ Simpler to understand                │
│  ✓ Production-like workflow           ✓ No extra learning curve              │
│  ✓ Easy to modify/extend                                                     │
│  ✓ ArgoCD installed automatically                                            │
│                                                                              │
│  Best for: Full DevOps learning       Best for: K8s-only focus              │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## After Setup

### Access ArgoCD

| Setting | Value |
|---------|-------|
| URL | http://localhost:30080 |
| Username | admin |
| Password | (shown after setup, or run command below) |

```bash
# Get ArgoCD password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 -d && echo
```

### Start Learning

```bash
# Kubernetes basics
cd 01-kubernetes-basics && cat README.md

# Or jump to ArgoCD (after completing K8s basics)
cd 04-argocd-basics && cat README.md

# Or explore with k9s (terminal UI)
k9s
```

---

## Tool Versions (asdf)

All tools are pinned in `.tool-versions`:

```
kubectl   1.29.0    # Kubernetes CLI
kind      0.20.0    # Local clusters
helm      3.14.0    # Package manager
terraform 1.7.0     # Infrastructure as Code
argocd    2.10.0    # GitOps CLI
k9s       0.31.7    # Terminal UI
yq        4.40.5    # YAML processor
```

Upgrade a tool:
```bash
# Edit .tool-versions, then:
asdf install
```

---

## Cleanup

### Terraform (Option A)
```bash
./scripts/destroy-cluster-terraform.sh
```

### Bash (Option B)
```bash
./scripts/delete-cluster.sh
```

---

## Troubleshooting

### "terraform not found"
```bash
source ~/.asdf/asdf.sh
asdf install terraform
```

### "Cannot connect to cluster"
```bash
# For Terraform setup
export KUBECONFIG=$(pwd)/terraform/kubeconfig

# For bash setup
kubectl cluster-info
```

### "ArgoCD not accessible"
```bash
# Check pods are running
kubectl get pods -n argocd

# Check service
kubectl get svc -n argocd
```

### "Docker not running"
Start Docker Desktop on Windows, ensure WSL integration is enabled.

---

## Disk Space

```
Component                    Size
─────────────────────────────────
asdf + tools                 ~600 MB
Docker images                ~5 GB
Kubernetes data              ~2 GB
Terraform state              ~1 MB
─────────────────────────────────
TOTAL                        ~8 GB

Your 60 GB: ✅ Plenty of room!
```

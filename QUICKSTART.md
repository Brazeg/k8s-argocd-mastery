# Quick Start Guide

Get up and running in 10 minutes!

## Why asdf?

This lab uses **asdf** for tool version management:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    BENEFITS OF ASDF                                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ✓ PORTABLE        Share .tool-versions file, everyone gets same versions   │
│  ✓ ISOLATED        Different projects can use different versions            │
│  ✓ SIMPLE          One tool manages kubectl, helm, terraform, etc.          │
│  ✓ REPRODUCIBLE    Pin exact versions, no "works on my machine"             │
│                                                                              │
│  Example:                                                                    │
│  ─────────                                                                   │
│  Project A (.tool-versions):    Project B (.tool-versions):                  │
│    kubectl 1.28.0                 kubectl 1.29.0                             │
│    helm 3.13.0                    helm 3.14.0                                │
│                                                                              │
│  cd project-a → uses 1.28.0      cd project-b → uses 1.29.0                 │
│  Automatic switching!                                                        │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Option A: Setup with asdf (Recommended)

```bash
# 1. Run setup (installs asdf + all tools)
./scripts/setup.sh

# 2. Load asdf in your shell (or open new terminal)
source ~/.asdf/asdf.sh

# 3. Create Kubernetes cluster
./scripts/create-cluster.sh

# 4. Verify
kubectl get nodes
```

## Option B: Manual Setup (No asdf)

If you prefer not to use asdf:

```bash
./scripts/setup-manual.sh
./scripts/create-cluster.sh
```

---

## Tool Versions

All tool versions are pinned in `.tool-versions`:

```
kubectl   1.29.0
kind      0.20.0
helm      3.14.0
terraform 1.7.0
argocd    2.10.0
k9s       0.31.7
yq        4.40.5
```

To update a tool version:
```bash
# Edit .tool-versions, then:
asdf install
```

---

## Start Learning

```bash
# Kubernetes basics
cd 01-kubernetes-basics && cat README.md

# Or jump to ArgoCD
cd 04-argocd-basics && cat README.md
```

---

## Access Points (After Setup)

| Service | URL | Credentials |
|---------|-----|-------------|
| ArgoCD | http://localhost:30080 | admin / (see below) |
| Grafana | http://localhost:30081 | admin / admin |
| Demo App | http://localhost:30082 | N/A |

### Get ArgoCD Password

```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d && echo
```

---

## Useful Commands

```bash
# Switch tool versions (automatic when you cd into project)
cd /path/to/project-with-tool-versions

# Check current versions
asdf current

# List installed versions of a tool
asdf list kubectl

# Install a specific version
asdf install kubectl 1.30.0

# Set global default version
asdf global kubectl 1.29.0

# Set local version for this project only
asdf local kubectl 1.28.0
```

---

## Cleanup

```bash
# Delete cluster only
./scripts/delete-cluster.sh

# Full cleanup (remove tools installed by asdf)
asdf uninstall kubectl 1.29.0
asdf uninstall kind 0.20.0
# ... etc
```

---

## Disk Space

```
Component                    Size
─────────────────────────────────
asdf + plugins               ~100 MB
Tools (kubectl, helm, etc.)  ~500 MB
Docker images                ~5 GB
Kubernetes data              ~2 GB
─────────────────────────────────
TOTAL                        ~8 GB

Your 60 GB: ✅ Plenty of room!
```

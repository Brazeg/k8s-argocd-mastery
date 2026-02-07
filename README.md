# Kubernetes + ArgoCD Mastery Lab

A hands-on learning path from beginner to advanced, with portable tool management via **asdf**.

---

## Features

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         WHAT MAKES THIS LAB SPECIAL                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ✓ PORTABLE SETUP                                                            │
│    • asdf manages all tool versions                                          │
│    • .tool-versions file ensures consistency                                 │
│    • Share with teammates, everyone gets same environment                    │
│                                                                              │
│  ✓ STRUCTURED LEARNING                                                       │
│    • 8 modules from basics to production                                     │
│    • Each module has exercises + solutions                                   │
│    • Clear progression path                                                  │
│                                                                              │
│  ✓ HANDS-ON FOCUS                                                            │
│    • Real YAML files to apply                                                │
│    • Challenges to test understanding                                        │
│    • Production-like patterns                                                │
│                                                                              │
│  ✓ COMPLETE STACK                                                            │
│    • Kubernetes (Kind)                                                       │
│    • ArgoCD (GitOps)                                                         │
│    • LGTM Stack (Observability)                                              │
│    • Demo applications                                                       │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Learning Path

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         LEARNING JOURNEY                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  PHASE 1: KUBERNETES FUNDAMENTALS (Weeks 1-2)                                │
│  ═══════════════════════════════════════════                                 │
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

## Quick Start

```bash
# 1. Setup with asdf (recommended)
./scripts/setup.sh

# 2. Load asdf (or open new terminal)
source ~/.asdf/asdf.sh

# 3. Create cluster
./scripts/create-cluster.sh

# 4. Start learning
cd 01-kubernetes-basics
cat README.md
```

See [QUICKSTART.md](QUICKSTART.md) for detailed instructions.

---

## Project Structure

```
k8s-argocd-mastery/
│
├── .tool-versions              ← asdf tool versions (PORTABLE!)
│
├── scripts/
│   ├── setup.sh                ← Install asdf + all tools
│   ├── setup-manual.sh         ← Alternative: install without asdf
│   ├── create-cluster.sh       ← Create Kind cluster
│   └── delete-cluster.sh       ← Cleanup
│
├── 01-kubernetes-basics/       ← Pods, Deployments, Services
├── 02-kubernetes-intermediate/ ← ConfigMaps, Secrets, Volumes
├── 03-kubernetes-advanced/     ← RBAC, NetworkPolicies
├── 04-argocd-basics/           ← GitOps fundamentals
├── 05-argocd-intermediate/     ← Helm, Kustomize integration
├── 06-argocd-advanced/         ← ApplicationSets, Multi-cluster
├── 07-observability/           ← LGTM Stack
├── 08-production-patterns/     ← Real-world patterns
│
└── apps/                       ← Demo applications
    ├── demo-app/               ← Simple Helm chart
    └── tns/                    ← Observability demo
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
| 00 Setup | 30 min | Easy |
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
- Internet connection (for pulling images)

---

## Support

If something doesn't work:

1. Check Docker is running: `docker info`
2. Check asdf is loaded: `asdf current`
3. Re-run setup: `./scripts/setup.sh`
4. Delete and recreate cluster: `./scripts/delete-cluster.sh && ./scripts/create-cluster.sh`

---

## Next Steps After Completing the Lab

1. Deploy to real cloud (AKS, EKS, GKE)
2. Set up multi-cluster ArgoCD
3. Implement External Secrets Operator
4. Add Argo Rollouts for progressive delivery
5. Build your own Internal Developer Platform

---

**Happy Learning!** 🚀

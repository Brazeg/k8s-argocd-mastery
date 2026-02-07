# Module 03: Kubernetes Advanced

## Topics Covered

- RBAC (Role-Based Access Control)
- Network Policies
- Resource Quotas and Limit Ranges
- Pod Disruption Budgets
- Horizontal Pod Autoscaling
- Custom Resource Definitions (CRDs)

## Prerequisites
Complete Module 01 and 02 first.

## Exercises Coming Soon
This module builds on your intermediate knowledge.

---

Key concepts preview:

```
RBAC: WHO CAN DO WHAT?
══════════════════════

User/ServiceAccount ─── RoleBinding ─── Role
                                         │
                                         ├── get pods
                                         ├── list services
                                         └── create deployments


NETWORK POLICIES: POD FIREWALL
══════════════════════════════

┌─────────────────────────────────────────┐
│  Namespace: production                  │
│                                         │
│  ┌─────────┐      ┌─────────┐          │
│  │ Frontend│ ───▶ │ Backend │ ← ALLOWED │
│  └─────────┘      └─────────┘          │
│                        │               │
│                        │               │
│  ┌─────────┐           │               │
│  │ Attacker│ ────X─────┘  ← BLOCKED    │
│  └─────────┘                           │
└─────────────────────────────────────────┘


HORIZONTAL POD AUTOSCALER
═════════════════════════

CPU > 80%?
    │
    ├── YES → Scale up (add more pods)
    │
    └── NO  → CPU < 20%?
                  │
                  ├── YES → Scale down
                  │
                  └── NO  → Do nothing
```

# Module 06: ArgoCD Advanced

## Topics Covered

- ApplicationSets (generate apps from templates)
- App of Apps pattern
- Multi-cluster deployment
- Secrets management (External Secrets Operator)
- Progressive delivery (Argo Rollouts)
- Disaster recovery

## Prerequisites
Complete Module 04 and 05 first.

---

## Key Concepts Preview

```
APPLICATIONSET
══════════════

Template + Generator = Multiple Applications

Generator: List of clusters
┌─────────────────────┐
│ - dev-cluster       │
│ - staging-cluster   │
│ - prod-cluster      │
└─────────────────────┘
           ↓
      ApplicationSet
           ↓
┌─────────────────────┐
│ App: myapp-dev      │
│ App: myapp-staging  │
│ App: myapp-prod     │
└─────────────────────┘

One template → Multiple apps!


MULTI-CLUSTER
═════════════

┌──────────────────────────────────────────────────────────┐
│                    Management Cluster                     │
│                                                          │
│    ┌────────────────────────────────────────────────┐   │
│    │                   ArgoCD                        │   │
│    │                                                 │   │
│    │   ┌─────────┐  ┌─────────┐  ┌─────────┐       │   │
│    │   │ App 1   │  │ App 2   │  │ App 3   │       │   │
│    │   └────┬────┘  └────┬────┘  └────┬────┘       │   │
│    │        │            │            │             │   │
│    └────────┼────────────┼────────────┼─────────────┘   │
│             │            │            │                  │
└─────────────┼────────────┼────────────┼──────────────────┘
              │            │            │
              ▼            ▼            ▼
        ┌─────────┐  ┌─────────┐  ┌─────────┐
        │   Dev   │  │ Staging │  │  Prod   │
        │ Cluster │  │ Cluster │  │ Cluster │
        └─────────┘  └─────────┘  └─────────┘
```

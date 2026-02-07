# Module 08: Production Patterns

## Topics Covered

- Multi-environment setup (dev/staging/prod)
- Secrets management strategies
- Policy enforcement (Kyverno/OPA Gatekeeper)
- GitOps repository structure
- Disaster recovery
- Compliance and auditing

## Prerequisites
Complete all previous modules.

---

## Key Concepts Preview

```
REPOSITORY STRUCTURE FOR PRODUCTION
════════════════════════════════════

gitops-repo/
├── apps/
│   ├── base/                 ← Common configuration
│   │   └── my-app/
│   │       ├── deployment.yaml
│   │       └── service.yaml
│   │
│   └── overlays/             ← Environment-specific
│       ├── dev/
│       │   └── kustomization.yaml
│       ├── staging/
│       │   └── kustomization.yaml
│       └── prod/
│           └── kustomization.yaml
│
└── argocd-apps/
    ├── dev.yaml
    ├── staging.yaml
    └── prod.yaml


SECRETS MANAGEMENT
══════════════════

Option 1: Sealed Secrets
  Secret → Encrypt → Store in Git → Decrypt in cluster

Option 2: External Secrets Operator
  Secret in Vault/AWS → ESO fetches → Creates K8s Secret

Option 3: SOPS + Age
  Encrypt YAML files → Store in Git → Decrypt during apply


POLICY ENFORCEMENT
══════════════════

Before pod created:
  │
  ├── Does it have resource limits? ✓
  ├── Is image from allowed registry? ✓
  ├── Is it running as non-root? ✓
  │
  └── All checks pass → Pod created
```

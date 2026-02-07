# Module 05: ArgoCD Intermediate

## Topics Covered

- Helm integration
- Kustomize integration
- Sync waves and hooks
- Resource hooks (PreSync, PostSync)
- Multiple sources
- ApplicationSets basics

## Prerequisites
Complete Module 04 first.

---

## Key Concepts Preview

```
HELM VS KUSTOMIZE
═════════════════

Helm: Template engine
────────────────────
values.yaml + templates → rendered YAML

  replicas: {{ .Values.replicas }}
           ↓
  replicas: 3


Kustomize: Overlay system
─────────────────────────
base YAML + patches → merged YAML

  base/deployment.yaml
  + overlays/prod/patch.yaml
  = final deployment


SYNC WAVES
══════════

Wave 0: Namespace, ConfigMaps
         ↓
Wave 1: Database
         ↓
Wave 2: Backend
         ↓
Wave 3: Frontend

Each wave completes before next starts!


HOOKS
═════

PreSync  → Run BEFORE sync (migrations, backups)
Sync     → Normal sync
PostSync → Run AFTER sync (notifications, tests)
```

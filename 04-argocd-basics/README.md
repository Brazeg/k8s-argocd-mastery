# Module 04: ArgoCD Basics

## Learning Objectives

- Understand GitOps principles
- Install and access ArgoCD
- Create your first ArgoCD Application
- Understand sync, health, and status
- Manual vs automatic sync

---

## Concept 1: What is GitOps?

```
TRADITIONAL DEPLOYMENT
══════════════════════

Developer → writes code → CI builds image → CD runs kubectl apply → Cluster
                                                   │
                                                   └── Manual intervention
                                                   └── No history
                                                   └── "Who deployed this?"


GITOPS DEPLOYMENT
═════════════════

Developer → writes code + K8s manifests → pushes to Git → ArgoCD watches
                                              │                  │
                                              │                  ▼
                                         Git is the          ArgoCD syncs
                                         source of           automatically
                                         truth               to cluster
                                              │                  │
                                              └──────────────────┘
                                                       │
                                                       ▼
                                              • Full audit trail
                                              • Easy rollback (git revert)
                                              • Consistent state
                                              • Self-healing
```

### GitOps Principles

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          GITOPS PRINCIPLES                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  1. DECLARATIVE                                                              │
│     Everything described as code (YAML)                                      │
│     "I want 3 replicas" not "create replica, create replica, create replica"│
│                                                                              │
│  2. VERSIONED & IMMUTABLE                                                    │
│     All changes stored in Git                                                │
│     Every change has a commit hash, author, timestamp                        │
│                                                                              │
│  3. PULLED AUTOMATICALLY                                                     │
│     ArgoCD pulls from Git (vs pushing to cluster)                            │
│     Cluster doesn't need Git credentials exposed                             │
│                                                                              │
│  4. CONTINUOUSLY RECONCILED                                                  │
│     ArgoCD constantly compares Git vs Cluster                                │
│     Any drift is detected and can be auto-fixed                              │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Exercise 4.1: Install ArgoCD

```bash
# Create namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for pods to be ready (takes 1-2 minutes)
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Check all pods are running
kubectl get pods -n argocd
```

### Make ArgoCD Accessible

```bash
# Option 1: Port-forward (quick for learning)
kubectl port-forward svc/argocd-server -n argocd 8080:443 &

# Option 2: NodePort (better for ongoing use)
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort", "ports": [{"port": 443, "nodePort": 30080}]}}'
```

### Get Admin Password

```bash
# The initial password is stored in a secret
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo  # Add newline for readability
```

### Access the UI

1. Open browser: `https://localhost:8080` (or `http://localhost:30080`)
2. Accept the self-signed certificate warning
3. Login:
   - Username: `admin`
   - Password: (from the command above)

---

## Concept 2: ArgoCD Components

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       ARGOCD ARCHITECTURE                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   ┌─────────────────────────────────────────────────────────────┐           │
│   │                    ArgoCD Server (UI + API)                  │           │
│   │                                                              │           │
│   │   • Web interface you just logged into                       │           │
│   │   • REST API for automation                                  │           │
│   │   • Handles authentication                                   │           │
│   └──────────────────────┬──────────────────────────────────────┘           │
│                          │                                                   │
│   ┌──────────────────────┴──────────────────────────────────────┐           │
│   │                    Application Controller                    │           │
│   │                                                              │           │
│   │   • Watches Git repositories                                 │           │
│   │   • Compares desired state (Git) vs actual state (Cluster)  │           │
│   │   • Performs sync operations                                 │           │
│   └──────────────────────┬──────────────────────────────────────┘           │
│                          │                                                   │
│   ┌──────────────────────┴──────────────────────────────────────┐           │
│   │                    Repo Server                               │           │
│   │                                                              │           │
│   │   • Clones Git repositories                                  │           │
│   │   • Generates Kubernetes manifests from Helm/Kustomize       │           │
│   │   • Caches repository data                                   │           │
│   └─────────────────────────────────────────────────────────────┘           │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Concept 3: ArgoCD Application

An "Application" in ArgoCD connects a Git repository to a Kubernetes cluster.

```
ARGOCD APPLICATION
══════════════════

┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                              │
│   Application: "my-app"                                                      │
│                                                                              │
│   SOURCE                              DESTINATION                            │
│   ────────────────────────            ────────────────────────               │
│   Repository: github.com/...          Cluster: https://kubernetes...        │
│   Path: apps/my-app/                  Namespace: my-app                      │
│   Branch: main                                                               │
│                                                                              │
│   SYNC POLICY                                                                │
│   ────────────────────────                                                   │
│   • Auto-sync: yes/no                                                        │
│   • Self-heal: yes/no                                                        │
│   • Prune: yes/no                                                            │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Exercise 4.2: Create Your First Application (UI)

Let's use a public example repository first.

1. Open ArgoCD UI
2. Click **"+ NEW APP"**
3. Fill in:
   - **Application Name**: `guestbook`
   - **Project**: `default`
   - **Sync Policy**: `Manual`
   - **Repository URL**: `https://github.com/argoproj/argocd-example-apps.git`
   - **Path**: `guestbook`
   - **Cluster URL**: `https://kubernetes.default.svc`
   - **Namespace**: `guestbook`
4. Click **CREATE**

### Observe the Application

1. The app appears with status **"OutOfSync"**
   - This means: Git has resources, but cluster doesn't have them yet
2. Click on the application to see details
3. Click **"SYNC"** → **"SYNCHRONIZE"**
4. Watch the resources being created!

### Verify in Kubernetes

```bash
# Check the namespace was created
kubectl get namespace guestbook

# Check the pods
kubectl get pods -n guestbook

# Check services
kubectl get svc -n guestbook
```

---

## Exercise 4.3: Create Application via CLI

```bash
# Login to ArgoCD CLI
argocd login localhost:8080 --insecure --username admin --password $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

# Create an application
argocd app create guestbook-cli \
  --repo https://github.com/argoproj/argocd-example-apps.git \
  --path guestbook \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace guestbook-cli

# Check status
argocd app get guestbook-cli

# Sync it
argocd app sync guestbook-cli

# List all apps
argocd app list
```

---

## Exercise 4.4: Create Application via YAML

Create `exercises/guestbook-app.yaml`:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: guestbook-yaml
  namespace: argocd        # ArgoCD apps always live in argocd namespace
spec:
  project: default
  
  source:
    repoURL: https://github.com/argoproj/argocd-example-apps.git
    targetRevision: HEAD   # Branch, tag, or commit
    path: guestbook        # Folder in the repo
  
  destination:
    server: https://kubernetes.default.svc
    namespace: guestbook-yaml
  
  syncPolicy:
    syncOptions:
      - CreateNamespace=true   # Create namespace if it doesn't exist
```

```bash
kubectl apply -f exercises/guestbook-app.yaml

# Check in ArgoCD UI - it appears!
# Or via CLI:
argocd app get guestbook-yaml
```

---

## Concept 4: Sync Status & Health

```
APPLICATION STATUS
══════════════════

┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                              │
│  SYNC STATUS (Git vs Cluster)                                                │
│  ─────────────────────────────                                               │
│                                                                              │
│  ✓ Synced     = Git and Cluster match                                       │
│  ✗ OutOfSync  = Git and Cluster are different                               │
│  ? Unknown    = ArgoCD can't determine status                                │
│                                                                              │
│                                                                              │
│  HEALTH STATUS (Are resources working?)                                      │
│  ──────────────────────────────────────                                      │
│                                                                              │
│  💚 Healthy     = All resources are working                                  │
│  💛 Progressing = Resources are starting up                                  │
│  💔 Degraded    = Some resources have problems                               │
│  ❤️ Suspended   = Resource is paused                                         │
│  ❓ Missing     = Resource doesn't exist in cluster                          │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Exercise 4.5: Understand Sync Status

```bash
# Make a manual change in the cluster (simulating drift)
kubectl scale deployment guestbook-ui -n guestbook --replicas=5

# Check ArgoCD - it shows OutOfSync!
argocd app get guestbook

# See the diff
argocd app diff guestbook

# Sync to restore desired state
argocd app sync guestbook

# Check replicas - back to original!
kubectl get deployment guestbook-ui -n guestbook
```

---

## Concept 5: Sync Policies

```
SYNC POLICY OPTIONS
═══════════════════

┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                              │
│  MANUAL SYNC (Default)                                                       │
│  ─────────────────────                                                       │
│  • You push to Git                                                           │
│  • ArgoCD detects change                                                     │
│  • YOU click Sync button                                                     │
│  • Changes applied                                                           │
│                                                                              │
│  Good for: Production, when you want control                                 │
│                                                                              │
│                                                                              │
│  AUTOMATIC SYNC                                                              │
│  ──────────────                                                              │
│  • You push to Git                                                           │
│  • ArgoCD detects change                                                     │
│  • ArgoCD AUTOMATICALLY syncs                                                │
│                                                                              │
│  Good for: Dev/staging environments                                          │
│                                                                              │
│                                                                              │
│  SELF-HEAL                                                                   │
│  ─────────                                                                   │
│  • Someone makes manual change in cluster                                    │
│  • ArgoCD detects drift from Git                                             │
│  • ArgoCD AUTOMATICALLY reverts to Git state                                 │
│                                                                              │
│  Good for: Preventing unauthorized changes                                   │
│                                                                              │
│                                                                              │
│  PRUNE                                                                       │
│  ─────                                                                       │
│  • You delete a resource from Git                                            │
│  • ArgoCD detects it's no longer in Git                                      │
│  • ArgoCD DELETES it from cluster too                                        │
│                                                                              │
│  Good for: Keeping cluster clean                                             │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Exercise 4.6: Enable Auto-Sync

Update the application:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: guestbook-auto
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/argoproj/argocd-example-apps.git
    targetRevision: HEAD
    path: guestbook
  destination:
    server: https://kubernetes.default.svc
    namespace: guestbook-auto
  
  syncPolicy:
    automated:              # Enable auto-sync
      selfHeal: true        # Revert manual changes
      prune: true           # Delete resources not in Git
    syncOptions:
      - CreateNamespace=true
```

```bash
kubectl apply -f exercises/guestbook-auto.yaml

# Now try to break it
kubectl delete deployment guestbook-ui -n guestbook-auto

# Wait a few seconds... ArgoCD recreates it!
kubectl get pods -n guestbook-auto -w
```

---

## Exercise 4.7: Use Your Own Repository

Now let's use your own Git repo!

### Step 1: Create a GitHub Repository

1. Go to GitHub
2. Create new repo: `argocd-learning`
3. Clone it locally

### Step 2: Add a Simple Application

Create `apps/nginx/deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:1.24
          ports:
            - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx
spec:
  type: NodePort
  selector:
    app: nginx
  ports:
    - port: 80
      nodePort: 30084
```

### Step 3: Push to Git

```bash
git add .
git commit -m "Add nginx application"
git push
```

### Step 4: Create ArgoCD Application

```bash
argocd app create my-nginx \
  --repo https://github.com/YOUR_USERNAME/argocd-learning.git \
  --path apps/nginx \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace my-nginx \
  --sync-option CreateNamespace=true

argocd app sync my-nginx
```

### Step 5: Make a Change via Git

Edit `apps/nginx/deployment.yaml`:
- Change `replicas: 2` to `replicas: 4`

```bash
git add .
git commit -m "Scale to 4 replicas"
git push
```

Check ArgoCD - it shows OutOfSync! Sync it and watch the pods scale.

---

## Module 04 Challenges

### Challenge 1: Full GitOps Workflow
1. Create a new application in your Git repo
2. Register it in ArgoCD
3. Make 3 different changes via Git
4. Practice syncing and checking status

### Challenge 2: Self-Healing Demo
1. Enable auto-sync with self-heal
2. Use kubectl to manually change something
3. Watch ArgoCD fix it

### Challenge 3: Rollback
1. Deploy version 1 of your app
2. Update to version 2 via Git
3. Use ArgoCD to rollback to version 1

---

## Key Commands Reference

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    ARGOCD CLI CHEAT SHEET                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  CONNECTION                                                                  │
│  ──────────                                                                  │
│  argocd login <server>              Connect to ArgoCD                        │
│  argocd account list                List accounts                            │
│                                                                              │
│  APPLICATIONS                                                                │
│  ────────────                                                                │
│  argocd app list                    List all apps                            │
│  argocd app get <app>               Show app details                         │
│  argocd app create ...              Create new app                           │
│  argocd app delete <app>            Delete app                               │
│                                                                              │
│  SYNC OPERATIONS                                                             │
│  ───────────────                                                             │
│  argocd app sync <app>              Sync app with Git                        │
│  argocd app diff <app>              Show diff Git vs Cluster                 │
│  argocd app wait <app>              Wait for app to be healthy               │
│                                                                              │
│  ROLLBACK                                                                    │
│  ────────                                                                    │
│  argocd app history <app>           Show deployment history                  │
│  argocd app rollback <app> <id>     Rollback to previous version             │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Next Module

```bash
cd ../05-argocd-intermediate
cat README.md
```

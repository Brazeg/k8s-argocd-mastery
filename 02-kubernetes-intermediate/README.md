# Module 02: Kubernetes Intermediate

## Learning Objectives

- ConfigMaps and Secrets (application configuration)
- Persistent Volumes (data that survives pod restarts)
- Ingress (HTTP routing)
- Health checks (liveness & readiness probes)

---

## Concept 1: ConfigMaps

ConfigMaps store non-sensitive configuration data.

```
WHY CONFIGMAPS?
═══════════════

Bad: Hardcoded config in container image
┌────────────────────────────────────────┐
│  Container Image                       │
│  ┌──────────────────────────────────┐ │
│  │ DATABASE_URL=prod-db.company.com │ │  ← Rebuild image to change!
│  │ LOG_LEVEL=info                   │ │
│  └──────────────────────────────────┘ │
└────────────────────────────────────────┘

Good: Config separate from image
┌────────────────────┐    ┌────────────────────┐
│  Container Image   │    │    ConfigMap       │
│  ┌──────────────┐  │    │ DATABASE_URL=...   │
│  │  App code    │◄─┼────│ LOG_LEVEL=debug    │  ← Change without rebuild!
│  │  (no config) │  │    └────────────────────┘
│  └──────────────┘  │
└────────────────────┘
```

### Exercise 2.1: ConfigMap from Literal Values

```bash
# Create ConfigMap
kubectl create configmap app-config \
  --from-literal=DATABASE_HOST=mysql.default.svc \
  --from-literal=LOG_LEVEL=debug

# View it
kubectl get configmap app-config -o yaml

# Describe it
kubectl describe configmap app-config
```

### Exercise 2.2: ConfigMap from File

Create `exercises/app.properties`:
```
database.host=mysql.default.svc
database.port=3306
log.level=info
feature.new-ui=true
```

```bash
kubectl create configmap app-config-file --from-file=exercises/app.properties
kubectl get configmap app-config-file -o yaml
```

### Exercise 2.3: Using ConfigMap in a Pod

Create `exercises/pod-with-configmap.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-with-config
spec:
  containers:
    - name: app
      image: busybox
      command: ['sh', '-c', 'echo "DB Host: $DATABASE_HOST"; echo "Log Level: $LOG_LEVEL"; sleep 3600']
      env:
        # Individual values from ConfigMap
        - name: DATABASE_HOST
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: DATABASE_HOST
        - name: LOG_LEVEL
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: LOG_LEVEL
```

```bash
kubectl apply -f exercises/pod-with-configmap.yaml
kubectl logs app-with-config
```

---

## Concept 2: Secrets

Secrets are like ConfigMaps, but for sensitive data. 
Values are base64 encoded (NOT encrypted by default!).

```
CONFIGMAP vs SECRET
═══════════════════

ConfigMap:               Secret:
• Database host          • Database password
• Log level              • API keys
• Feature flags          • TLS certificates
• Public URLs            • OAuth tokens
```

### Exercise 2.4: Create and Use Secrets

```bash
# Create secret
kubectl create secret generic db-credentials \
  --from-literal=username=admin \
  --from-literal=password=supersecret123

# View (values are base64 encoded)
kubectl get secret db-credentials -o yaml

# Decode a value
kubectl get secret db-credentials -o jsonpath='{.data.password}' | base64 -d
```

Create `exercises/pod-with-secret.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-with-secrets
spec:
  containers:
    - name: app
      image: busybox
      command: ['sh', '-c', 'echo "User: $DB_USER"; echo "Pass: $DB_PASS"; sleep 3600']
      env:
        - name: DB_USER
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: username
        - name: DB_PASS
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: password
```

---

## Concept 3: Persistent Volumes

By default, container storage is temporary (ephemeral). 
Persistent Volumes (PV) keep data even when pods restart.

```
WITHOUT PERSISTENT VOLUME
═════════════════════════

┌─────────┐         ┌─────────┐
│  Pod    │  dies   │ New Pod │
│ ┌─────┐ │  ───►   │ ┌─────┐ │
│ │Data │ │         │ │Empty│ │   ← Data lost!
│ └─────┘ │         │ └─────┘ │
└─────────┘         └─────────┘


WITH PERSISTENT VOLUME
══════════════════════

┌─────────┐         ┌─────────┐
│  Pod    │  dies   │ New Pod │
│    │    │  ───►   │    │    │
│    ▼    │         │    ▼    │
│ ┌─────┐ │         │ ┌─────┐ │
└─┤ PVC ├─┘         └─┤ PVC ├─┘
  └──┬──┘             └──┬──┘
     │                   │
     └───────┬───────────┘
             ▼
      ┌────────────┐
      │     PV     │   ← Data persists!
      │  (storage) │
      └────────────┘
```

### Exercise 2.5: Persistent Volume

Create `exercises/pvc-example.yaml`:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-storage
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
---
apiVersion: v1
kind: Pod
metadata:
  name: pod-with-storage
spec:
  containers:
    - name: app
      image: busybox
      command: ['sh', '-c', 'echo "Hello from pod" >> /data/log.txt; cat /data/log.txt; sleep 3600']
      volumeMounts:
        - name: my-volume
          mountPath: /data
  volumes:
    - name: my-volume
      persistentVolumeClaim:
        claimName: my-storage
```

```bash
kubectl apply -f exercises/pvc-example.yaml

# Check the log
kubectl logs pod-with-storage

# Delete pod
kubectl delete pod pod-with-storage

# Recreate - data should persist!
kubectl apply -f exercises/pvc-example.yaml
kubectl logs pod-with-storage
# You'll see "Hello from pod" twice!
```

---

## Concept 4: Health Checks (Probes)

Kubernetes can check if your application is healthy.

```
THREE TYPES OF PROBES
═════════════════════

Liveness Probe:
  "Is the app still alive?"
  If fails → Kubernetes RESTARTS the pod

Readiness Probe:
  "Is the app ready to receive traffic?"
  If fails → Kubernetes STOPS sending traffic (but doesn't restart)

Startup Probe:
  "Has the app finished starting?"
  Used for slow-starting applications
```

### Exercise 2.6: Health Checks

Create `exercises/pod-with-probes.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-with-probes
spec:
  containers:
    - name: nginx
      image: nginx
      ports:
        - containerPort: 80
      
      # Is the container alive?
      livenessProbe:
        httpGet:
          path: /
          port: 80
        initialDelaySeconds: 5
        periodSeconds: 10
      
      # Is it ready for traffic?
      readinessProbe:
        httpGet:
          path: /
          port: 80
        initialDelaySeconds: 2
        periodSeconds: 5
```

```bash
kubectl apply -f exercises/pod-with-probes.yaml
kubectl describe pod app-with-probes
# Look for the Liveness and Readiness sections
```

---

## Concept 5: Resource Requests and Limits

Tell Kubernetes how much CPU/memory your app needs.

```
REQUESTS vs LIMITS
══════════════════

Requests: "I need at least this much"
  → Kubernetes uses this for scheduling

Limits: "Never give me more than this"
  → Container gets killed if it exceeds memory limit
```

### Exercise 2.7: Resource Management

Create `exercises/pod-with-resources.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: resource-demo
spec:
  containers:
    - name: app
      image: nginx
      resources:
        requests:
          memory: "64Mi"    # 64 Megabytes minimum
          cpu: "100m"       # 0.1 CPU cores minimum
        limits:
          memory: "128Mi"   # 128 Megabytes maximum
          cpu: "200m"       # 0.2 CPU cores maximum
```

```bash
kubectl apply -f exercises/pod-with-resources.yaml
kubectl describe pod resource-demo
# Look for the "Requests" and "Limits" section
```

---

## Module 02 Challenges

### Challenge 1: Complete Application Stack
Create a setup with:
1. A ConfigMap for application settings
2. A Secret for database credentials
3. A Deployment that uses both
4. A Service to expose it

### Challenge 2: Simulate Failure
1. Create a pod with a liveness probe
2. Make it fail (hint: exec into the pod and delete the index.html)
3. Watch Kubernetes restart it

---

## Next Module

```bash
cd ../03-kubernetes-advanced
cat README.md
```

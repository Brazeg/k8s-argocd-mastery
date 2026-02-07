# Module 07: Observability with LGTM Stack

## Learning Objectives

- Understand the three pillars of observability (Logs, Metrics, Traces)
- Deploy Grafana LGTM stack via ArgoCD
- Create dashboards and explore data
- Correlate logs, metrics, and traces

---

## The Three Pillars of Observability

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    THREE PILLARS OF OBSERVABILITY                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  LOGS                              "What happened?"                          │
│  ────                                                                        │
│  • Text messages from your application                                       │
│  • "User 123 logged in at 10:45"                                             │
│  • "Error: Connection to database failed"                                    │
│  • Tool: Loki                                                                │
│                                                                              │
│                                                                              │
│  METRICS                           "How many? How fast? How much?"           │
│  ───────                                                                     │
│  • Numbers over time                                                         │
│  • CPU usage: 45%                                                            │
│  • Requests per second: 150                                                  │
│  • Response time: 234ms                                                      │
│  • Tool: Mimir (or Prometheus)                                               │
│                                                                              │
│                                                                              │
│  TRACES                            "What was the journey?"                   │
│  ──────                                                                      │
│  • Follow a request across services                                          │
│  • User request → API → Auth → Database → Response                           │
│  • Where did it slow down? Where did it fail?                                │
│  • Tool: Tempo                                                               │
│                                                                              │
│                                                                              │
│  GRAFANA                           "Show me everything"                      │
│  ───────                                                                     │
│  • Visualization layer                                                       │
│  • Dashboards, alerts, exploration                                           │
│  • Connects to Loki, Mimir, Tempo                                            │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘


HOW THEY CONNECT
════════════════

     User Request
          │
          ▼
    ┌───────────┐
    │   App     │ ──── Logs ────────────────────────▶ LOKI
    │           │ ──── Metrics ─────────────────────▶ MIMIR
    │           │ ──── Traces ──────────────────────▶ TEMPO
    └───────────┘                                       │
                                                        │
                                                        ▼
                                                   ┌─────────┐
                                                   │ GRAFANA │
                                                   │         │
                                                   │ 📊 📈 📉 │
                                                   └─────────┘

     "Show me the trace for request abc123"
     "Show me error logs from the last hour"
     "Show me CPU usage trend this week"
```

---

## Exercise 7.1: Deploy LGTM Stack

We'll deploy this using ArgoCD (GitOps style!).

### Create the Helm Chart

Create `lgtm-stack/Chart.yaml`:

```yaml
apiVersion: v2
name: lgtm-stack
description: Grafana LGTM Stack for observability
version: 1.0.0

dependencies:
  - name: grafana
    version: "7.0.17"
    repository: "https://grafana.github.io/helm-charts"
  
  - name: loki
    version: "5.41.4"
    repository: "https://grafana.github.io/helm-charts"
  
  - name: tempo
    version: "1.7.1"
    repository: "https://grafana.github.io/helm-charts"
  
  - name: promtail
    version: "6.15.3"
    repository: "https://grafana.github.io/helm-charts"
```

Create `lgtm-stack/values.yaml`:

```yaml
# Grafana
grafana:
  service:
    type: NodePort
    nodePort: 30081
  adminUser: admin
  adminPassword: admin
  
  datasources:
    datasources.yaml:
      apiVersion: 1
      datasources:
        - name: Loki
          type: loki
          url: http://lgtm-stack-loki-gateway:80
          access: proxy
        - name: Tempo
          type: tempo
          url: http://lgtm-stack-tempo:3100
          access: proxy

# Loki (simplified for learning)
loki:
  deploymentMode: SingleBinary
  loki:
    auth_enabled: false
    commonConfig:
      replication_factor: 1
    storage:
      type: filesystem
  singleBinary:
    replicas: 1
  backend:
    replicas: 0
  read:
    replicas: 0
  write:
    replicas: 0
  gateway:
    enabled: true

# Tempo (tracing)
tempo:
  tempo:
    receivers:
      otlp:
        protocols:
          grpc:
            endpoint: "0.0.0.0:4317"
          http:
            endpoint: "0.0.0.0:4318"

# Promtail (log collector)
promtail:
  config:
    clients:
      - url: http://lgtm-stack-loki-gateway:80/loki/api/v1/push
```

### Deploy via ArgoCD

```bash
# First, update Helm dependencies
cd lgtm-stack
helm dependency update
cd ..

# Commit to Git (your repo)
git add .
git commit -m "Add LGTM stack"
git push

# Create ArgoCD application
argocd app create lgtm-stack \
  --repo https://github.com/YOUR_USERNAME/argocd-learning.git \
  --path lgtm-stack \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace monitoring \
  --sync-option CreateNamespace=true

argocd app sync lgtm-stack
```

### Access Grafana

```bash
# Wait for pods
kubectl get pods -n monitoring -w

# Access Grafana
# URL: http://localhost:30081
# User: admin
# Password: admin
```

---

## Exercise 7.2: Deploy Demo Application (TNS)

The TNS app generates logs, metrics, and traces for testing.

Create `apps/tns/deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: tns-db
spec:
  replicas: 1
  selector:
    matchLabels:
      app: tns-db
  template:
    metadata:
      labels:
        app: tns-db
    spec:
      containers:
        - name: tns-db
          image: grafana/tns-db:latest
          ports:
            - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: tns-db
spec:
  selector:
    app: tns-db
  ports:
    - port: 80
      targetPort: 8080
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: tns-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: tns-app
  template:
    metadata:
      labels:
        app: tns-app
    spec:
      containers:
        - name: tns-app
          image: grafana/tns-app:latest
          args:
            - http://tns-db
          ports:
            - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: tns-app
spec:
  type: NodePort
  selector:
    app: tns-app
  ports:
    - port: 80
      targetPort: 8080
      nodePort: 30082
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: tns-loadgen
spec:
  replicas: 1
  selector:
    matchLabels:
      app: tns-loadgen
  template:
    metadata:
      labels:
        app: tns-loadgen
    spec:
      containers:
        - name: tns-loadgen
          image: grafana/tns-loadgen:latest
          args:
            - http://tns-app
```

---

## Exercise 7.3: Explore Logs in Grafana

1. Open Grafana: `http://localhost:30081`
2. Go to **Explore** (compass icon on left)
3. Select **Loki** data source
4. Try these queries:

```
# All logs from tns namespace
{namespace="tns"}

# Only error logs
{namespace="tns"} |= "error"

# Logs from specific app
{namespace="tns", app="tns-app"}

# Parse and filter JSON logs
{namespace="tns"} | json | level="error"
```

---

## Exercise 7.4: Explore Traces in Grafana

1. Go to **Explore**
2. Select **Tempo** data source
3. Click **Search**
4. Select service: `tns-app`
5. Click **Run Query**
6. Click on a trace to see the full journey

---

## Module 07 Challenges

### Challenge 1: Create a Dashboard
Build a Grafana dashboard showing:
- Log volume over time
- Error rate
- Request latency (if metrics available)

### Challenge 2: Log to Trace Correlation
1. Find an error in logs
2. Extract the trace ID
3. Find the corresponding trace in Tempo

---

## Next Steps

```bash
cd ../08-production-patterns
cat README.md
```

# Module 01: Kubernetes Basics

## Learning Objectives

By the end of this module, you will understand:
- What Kubernetes is and why it exists
- Core concepts: Pods, Deployments, Services
- How to create, inspect, and debug resources
- Basic kubectl commands

## Prerequisites
- Cluster running (`../scripts/create-cluster.sh`)

---

## Concept 1: What is Kubernetes?

```
THE PROBLEM KUBERNETES SOLVES
═════════════════════════════

Before Kubernetes:
┌─────────────────────────────────────────────────────────────────┐
│  Server 1          Server 2          Server 3                   │
│  ┌─────────┐       ┌─────────┐       ┌─────────┐               │
│  │ App A   │       │ App B   │       │ App C   │               │
│  │ (down!) │       │ (slow)  │       │ (ok)    │               │
│  └─────────┘       └─────────┘       └─────────┘               │
│                                                                 │
│  • If App A crashes, manual restart                             │
│  • If Server 2 overloaded, manual migration                     │
│  • Scaling = buy more servers, configure manually               │
│  • Updating = risky, downtime                                   │
└─────────────────────────────────────────────────────────────────┘

With Kubernetes:
┌─────────────────────────────────────────────────────────────────┐
│                     KUBERNETES CLUSTER                          │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                   Control Plane                           │  │
│  │  "I manage everything. You tell me WHAT you want,        │  │
│  │   I figure out HOW to make it happen."                   │  │
│  └──────────────────────────────────────────────────────────┘  │
│                            │                                    │
│         ┌──────────────────┼──────────────────┐                │
│         ▼                  ▼                  ▼                │
│  ┌───────────┐      ┌───────────┐      ┌───────────┐          │
│  │  Node 1   │      │  Node 2   │      │  Node 3   │          │
│  │ ┌───┐┌───┐│      │ ┌───┐┌───┐│      │ ┌───┐┌───┐│          │
│  │ │App││App││      │ │App││App││      │ │App││App││          │
│  │ └───┘└───┘│      │ └───┘└───┘│      │ └───┘└───┘│          │
│  └───────────┘      └───────────┘      └───────────┘          │
│                                                                 │
│  • App crashes → Kubernetes restarts it automatically           │
│  • Node overloaded → Kubernetes moves apps                      │
│  • Need more capacity → "kubectl scale --replicas=10"           │
│  • Update → Rolling update, zero downtime                       │
└─────────────────────────────────────────────────────────────────┘
```

---

## Concept 2: Pods

A Pod is the smallest unit in Kubernetes. It wraps one or more containers.

```
POD = Container(s) + Shared Network + Shared Storage
═══════════════════════════════════════════════════

┌─────────────────────────────────────┐
│            POD                      │
│  ┌─────────────┐  ┌─────────────┐  │
│  │ Container 1 │  │ Container 2 │  │  ← Usually just 1 container
│  │ (main app)  │  │ (sidecar)   │  │
│  └─────────────┘  └─────────────┘  │
│         │                │          │
│         └────────┬───────┘          │
│                  │                  │
│           Shared Network            │  ← Same IP address
│           (localhost)               │
│                  │                  │
│           Shared Storage            │  ← Can share files
│           (volumes)                 │
└─────────────────────────────────────┘
```

### Exercise 1.1: Create Your First Pod

```bash
# Create a simple pod
kubectl run my-first-pod --image=nginx

# Check if it's running
kubectl get pods

# Get more details
kubectl get pods -o wide

# Describe the pod (lots of useful info!)
kubectl describe pod my-first-pod

# See the logs
kubectl logs my-first-pod

# Execute a command inside the pod
kubectl exec my-first-pod -- ls /usr/share/nginx/html

# Interactive shell inside the pod
kubectl exec -it my-first-pod -- /bin/bash
# (type 'exit' to leave)

# Delete the pod
kubectl delete pod my-first-pod
```

### Exercise 1.2: Create Pod from YAML

Create file `exercises/pod-nginx.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
    environment: learning
spec:
  containers:
    - name: nginx
      image: nginx:1.24
      ports:
        - containerPort: 80
```

Apply and explore:

```bash
# Create the pod
kubectl apply -f exercises/pod-nginx.yaml

# Check it
kubectl get pods

# Get the YAML back from Kubernetes
kubectl get pod nginx-pod -o yaml

# Delete it
kubectl delete -f exercises/pod-nginx.yaml
```

### Exercise 1.3: Multi-Container Pod

Create file `exercises/pod-multi-container.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: multi-container-pod
spec:
  containers:
    # Main application
    - name: nginx
      image: nginx
      ports:
        - containerPort: 80
      volumeMounts:
        - name: shared-logs
          mountPath: /var/log/nginx
    
    # Sidecar: reads logs and prints them
    - name: log-reader
      image: busybox
      command: ['sh', '-c', 'tail -f /logs/access.log']
      volumeMounts:
        - name: shared-logs
          mountPath: /logs
  
  volumes:
    - name: shared-logs
      emptyDir: {}
```

```bash
# Create it
kubectl apply -f exercises/pod-multi-container.yaml

# See both containers
kubectl get pod multi-container-pod

# Logs from specific container
kubectl logs multi-container-pod -c nginx
kubectl logs multi-container-pod -c log-reader

# Exec into specific container
kubectl exec -it multi-container-pod -c nginx -- /bin/bash
```

---

## Concept 3: Deployments

Pods alone are fragile. If a Pod dies, it stays dead. 
Deployments manage Pods and ensure the desired number are always running.

```
DEPLOYMENT vs POD
═════════════════

Pod alone:
┌─────┐
│ Pod │ ──── Dies ──── 💀 Gone forever
└─────┘

With Deployment:
┌────────────────────────────────────────┐
│            DEPLOYMENT                  │
│   "Always keep 3 pods running"         │
│                                        │
│   ┌─────┐  ┌─────┐  ┌─────┐           │
│   │ Pod │  │ Pod │  │ Pod │           │
│   └─────┘  └─────┘  └─────┘           │
│      │                                 │
│      │ Dies                            │
│      ▼                                 │
│      💀                                │
│      │                                 │
│      │ Deployment notices!             │
│      ▼                                 │
│   ┌─────┐  ┌─────┐  ┌─────┐           │
│   │ NEW │  │ Pod │  │ Pod │           │
│   │ Pod │  │     │  │     │           │
│   └─────┘  └─────┘  └─────┘           │
│                                        │
│   Back to 3 pods automatically!        │
└────────────────────────────────────────┘
```

### Exercise 1.4: Create a Deployment

```bash
# Create deployment with kubectl
kubectl create deployment nginx-deployment --image=nginx --replicas=3

# Watch the pods being created
kubectl get pods -w
# (Press Ctrl+C to stop watching)

# See the deployment
kubectl get deployments

# See more details
kubectl describe deployment nginx-deployment

# Scale it up
kubectl scale deployment nginx-deployment --replicas=5
kubectl get pods

# Scale it down
kubectl scale deployment nginx-deployment --replicas=2
kubectl get pods
```

### Exercise 1.5: Deployment YAML

Create file `exercises/deployment-nginx.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
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
          resources:
            requests:
              memory: "64Mi"
              cpu: "100m"
            limits:
              memory: "128Mi"
              cpu: "200m"
```

```bash
# Delete old deployment first
kubectl delete deployment nginx-deployment

# Create from YAML
kubectl apply -f exercises/deployment-nginx.yaml

# Check status
kubectl get deployment nginx-deployment
kubectl get pods -l app=nginx
```

### Exercise 1.6: Self-Healing Demo

```bash
# List pods
kubectl get pods -l app=nginx

# Delete one pod (copy a pod name from above)
kubectl delete pod <pod-name>

# Immediately check - Kubernetes creates a new one!
kubectl get pods -l app=nginx

# Watch the recreation
kubectl get pods -l app=nginx -w
```

---

## Concept 4: Services

Pods get random IP addresses that change when they restart.
Services provide a stable IP/DNS name to access your pods.

```
THE PROBLEM:
═══════════

┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│   User wants to access your app                                 │
│                │                                                │
│                ▼                                                │
│        "Which IP do I use?"                                     │
│                                                                 │
│   Pod 1: 10.244.0.5  ← Dies, new pod gets 10.244.0.9           │
│   Pod 2: 10.244.0.6  ← Dies, new pod gets 10.244.0.10          │
│   Pod 3: 10.244.0.7  ← Still running                           │
│                                                                 │
│   IPs keep changing! 😱                                         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘


THE SOLUTION: SERVICES
══════════════════════

┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│   User                                                          │
│     │                                                           │
│     ▼                                                           │
│  ┌─────────────────────────────────────┐                       │
│  │         SERVICE                      │                       │
│  │   Name: nginx-service                │                       │
│  │   IP: 10.96.45.123 (stable!)         │                       │
│  │   DNS: nginx-service.default.svc     │                       │
│  └─────────────────────────────────────┘                       │
│                    │                                            │
│        Load balances to all matching pods                       │
│                    │                                            │
│     ┌──────────────┼──────────────┐                            │
│     ▼              ▼              ▼                            │
│  ┌─────┐       ┌─────┐       ┌─────┐                           │
│  │Pod 1│       │Pod 2│       │Pod 3│                           │
│  └─────┘       └─────┘       └─────┘                           │
│                                                                 │
│  Pods can die and restart - Service IP never changes!          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Service Types

```
┌─────────────────────────────────────────────────────────────────┐
│                    SERVICE TYPES                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ClusterIP (default)                                             │
│  ───────────────────                                             │
│  • Only accessible INSIDE the cluster                            │
│  • Other pods can reach it                                       │
│  • Use for: internal services, databases                         │
│                                                                  │
│                                                                  │
│  NodePort                                                        │
│  ────────                                                        │
│  • Accessible from OUTSIDE the cluster                           │
│  • Opens a port (30000-32767) on every node                      │
│  • Use for: development, direct access                           │
│                                                                  │
│                                                                  │
│  LoadBalancer                                                    │
│  ────────────                                                    │
│  • Creates external load balancer (cloud provider)               │
│  • Gets a public IP address                                      │
│  • Use for: production web apps                                  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Exercise 1.7: Create a Service

Create file `exercises/service-nginx.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  type: NodePort
  selector:
    app: nginx          # Matches pods with label "app: nginx"
  ports:
    - port: 80          # Service port
      targetPort: 80    # Pod port
      nodePort: 30082   # External port (accessible from your browser)
```

```bash
# Create the service
kubectl apply -f exercises/service-nginx.yaml

# Check services
kubectl get services

# See endpoints (pod IPs the service routes to)
kubectl get endpoints nginx-service

# Access it! Open browser to:
# http://localhost:30082

# Or use curl
curl http://localhost:30082
```

### Exercise 1.8: Service Discovery (DNS)

```bash
# Create a debug pod
kubectl run debug --image=busybox --rm -it -- /bin/sh

# Inside the pod, try these:
nslookup nginx-service
wget -qO- http://nginx-service
exit
```

---

## Concept 5: Namespaces

Namespaces are like folders to organize your resources.

```
┌─────────────────────────────────────────────────────────────────┐
│                      CLUSTER                                     │
│                                                                  │
│   ┌─────────────────────┐    ┌─────────────────────┐            │
│   │ Namespace: default   │    │ Namespace: kube-system│           │
│   │                      │    │                      │           │
│   │ Your apps go here    │    │ Kubernetes internal  │           │
│   │                      │    │ components           │           │
│   └─────────────────────┘    └─────────────────────┘            │
│                                                                  │
│   ┌─────────────────────┐    ┌─────────────────────┐            │
│   │ Namespace: dev       │    │ Namespace: prod       │           │
│   │                      │    │                      │           │
│   │ Development env      │    │ Production env       │           │
│   │                      │    │                      │           │
│   └─────────────────────┘    └─────────────────────┘            │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Exercise 1.9: Working with Namespaces

```bash
# List namespaces
kubectl get namespaces

# See pods in a specific namespace
kubectl get pods -n kube-system

# Create a namespace
kubectl create namespace dev

# Create resources in that namespace
kubectl run dev-nginx --image=nginx -n dev

# List pods in dev namespace
kubectl get pods -n dev

# List ALL pods in ALL namespaces
kubectl get pods -A

# Delete namespace (and everything in it!)
kubectl delete namespace dev
```

---

## Summary: Essential kubectl Commands

```
┌─────────────────────────────────────────────────────────────────┐
│                 KUBECTL CHEAT SHEET                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  VIEWING RESOURCES                                               │
│  ─────────────────                                               │
│  kubectl get pods                    List pods                   │
│  kubectl get pods -o wide            More details                │
│  kubectl get pods -w                 Watch for changes           │
│  kubectl get all                     All resources               │
│  kubectl describe pod <name>         Full details                │
│                                                                  │
│  CREATING RESOURCES                                              │
│  ──────────────────                                              │
│  kubectl apply -f file.yaml          Create/update from file     │
│  kubectl create deployment ...       Create deployment           │
│  kubectl run <name> --image=...      Quick pod creation          │
│                                                                  │
│  MODIFYING RESOURCES                                             │
│  ───────────────────                                             │
│  kubectl edit deployment <name>      Edit in editor              │
│  kubectl scale deployment --replicas=N                           │
│  kubectl set image deployment/X Y=image:tag                      │
│                                                                  │
│  DEBUGGING                                                       │
│  ─────────                                                       │
│  kubectl logs <pod>                  View logs                   │
│  kubectl logs <pod> -f               Follow logs                 │
│  kubectl exec -it <pod> -- /bin/sh   Shell into pod             │
│  kubectl port-forward <pod> 8080:80  Forward port               │
│                                                                  │
│  DELETING RESOURCES                                              │
│  ──────────────────                                              │
│  kubectl delete pod <name>           Delete pod                  │
│  kubectl delete -f file.yaml         Delete from file            │
│  kubectl delete all --all            Delete everything (careful!)│
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Module 01 Challenges

Complete these before moving to Module 02:

### Challenge 1: Deploy a Complete Application
Deploy the `httpd` (Apache) web server with:
- 3 replicas
- A NodePort service on port 30083
- Labels: `app: apache`, `tier: frontend`

### Challenge 2: Debugging
1. Create a pod that will fail (bad image name)
2. Use kubectl commands to figure out why it's not running
3. Fix it

### Challenge 3: Rolling Update
1. Create a deployment with `nginx:1.23`
2. Update it to `nginx:1.24`
3. Watch the rolling update happen
4. Roll back to the previous version

Solutions are in `solutions/` folder.

---

## Next Module

When you've completed all exercises and challenges:

```bash
cd ../02-kubernetes-intermediate
cat README.md
```

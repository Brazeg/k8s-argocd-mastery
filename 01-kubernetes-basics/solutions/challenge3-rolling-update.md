# Challenge 3 Solution: Rolling Update

## Step 1: Create initial deployment
```bash
kubectl create deployment nginx-update --image=nginx:1.23 --replicas=3
kubectl get pods -l app=nginx-update
```

## Step 2: Update to new version
```bash
kubectl set image deployment/nginx-update nginx=nginx:1.24

# Watch the rolling update
kubectl rollout status deployment/nginx-update

# See the pods being replaced one by one
kubectl get pods -l app=nginx-update -w
```

## Step 3: Check rollout history
```bash
kubectl rollout history deployment/nginx-update
```

## Step 4: Roll back
```bash
kubectl rollout undo deployment/nginx-update

# Verify
kubectl describe deployment nginx-update | grep Image
```

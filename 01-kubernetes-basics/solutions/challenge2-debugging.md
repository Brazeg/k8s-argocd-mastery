# Challenge 2 Solution: Debugging

## Step 1: Create a broken pod
```bash
kubectl run broken-pod --image=nginx:nonexistent-tag
```

## Step 2: Check status
```bash
kubectl get pods
# You'll see: ErrImagePull or ImagePullBackOff

kubectl describe pod broken-pod
# Look at the Events section at the bottom
# You'll see: Failed to pull image "nginx:nonexistent-tag"
```

## Step 3: Fix it
```bash
kubectl set image pod/broken-pod broken-pod=nginx:1.24
# Or delete and recreate with correct image
kubectl delete pod broken-pod
kubectl run broken-pod --image=nginx:1.24
```

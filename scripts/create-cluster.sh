#!/bin/bash
set -e

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║     Creating Kind Cluster                                      ║"
echo "╚════════════════════════════════════════════════════════════════╝"

CLUSTER_NAME="k8s-lab"

# Check if cluster exists
if kind get clusters 2>/dev/null | grep -q "^${CLUSTER_NAME}$"; then
    echo "Cluster '${CLUSTER_NAME}' already exists."
    read -p "Delete and recreate? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        kind delete cluster --name ${CLUSTER_NAME}
    else
        echo "Using existing cluster."
        exit 0
    fi
fi

# Create cluster config
cat > /tmp/kind-config.yaml << 'KINDEOF'
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    extraPortMappings:
      # ArgoCD UI
      - containerPort: 30080
        hostPort: 30080
        protocol: TCP
      # Grafana
      - containerPort: 30081
        hostPort: 30081
        protocol: TCP
      # Demo app
      - containerPort: 30082
        hostPort: 30082
        protocol: TCP
      # Additional ports for learning
      - containerPort: 30083
        hostPort: 30083
        protocol: TCP
      - containerPort: 30084
        hostPort: 30084
        protocol: TCP
KINDEOF

echo "Creating cluster '${CLUSTER_NAME}'..."
kind create cluster --name ${CLUSTER_NAME} --config /tmp/kind-config.yaml

echo ""
echo "Verifying cluster..."
kubectl cluster-info
kubectl get nodes

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  ✓ Cluster ready!                                              ║"
echo "║                                                                 ║"
echo "║  Start learning: cd 01-kubernetes-basics && cat README.md      ║"
echo "╚════════════════════════════════════════════════════════════════╝"

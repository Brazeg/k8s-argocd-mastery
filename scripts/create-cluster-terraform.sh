#!/bin/bash
set -e

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║     Creating Infrastructure with Terraform                      ║"
echo "╚════════════════════════════════════════════════════════════════╝"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(dirname "$SCRIPT_DIR")"
TERRAFORM_DIR="$LAB_DIR/terraform"

# Check terraform is available
if ! command -v terraform &> /dev/null; then
    echo "ERROR: terraform not found!"
    echo "Run: asdf install terraform"
    exit 1
fi

# Check Docker
if ! docker info > /dev/null 2>&1; then
    echo "ERROR: Docker is not running!"
    exit 1
fi

cd "$TERRAFORM_DIR"

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "Step 1: Initializing Terraform..."
echo "═══════════════════════════════════════════════════════════════"
terraform init

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "Step 2: Planning infrastructure..."
echo "═══════════════════════════════════════════════════════════════"
terraform plan -out=tfplan

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "Step 3: Applying infrastructure..."
echo "═══════════════════════════════════════════════════════════════"
terraform apply tfplan

# Set kubeconfig
export KUBECONFIG="$TERRAFORM_DIR/kubeconfig"
echo ""
echo "Setting KUBECONFIG=$KUBECONFIG"

# Wait for ArgoCD to be ready
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "Step 4: Waiting for ArgoCD to be ready..."
echo "═══════════════════════════════════════════════════════════════"
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd 2>/dev/null || true

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "Step 5: Getting ArgoCD password..."
echo "═══════════════════════════════════════════════════════════════"
sleep 5  # Give it a moment for the secret to be created

ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" 2>/dev/null | base64 -d)

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  ✓ Infrastructure Ready!                                       ║"
echo "╠════════════════════════════════════════════════════════════════╣"
echo "║                                                                 ║"
echo "║  ArgoCD UI: http://localhost:30080                              ║"
echo "║  Username:  admin                                               ║"
echo "║  Password:  $ARGOCD_PASSWORD"
echo "║                                                                 ║"
echo "║  IMPORTANT: Set your KUBECONFIG:                                ║"
echo "║  export KUBECONFIG=$TERRAFORM_DIR/kubeconfig"
echo "║                                                                 ║"
echo "║  Or add to ~/.bashrc for persistence                            ║"
echo "║                                                                 ║"
echo "╚════════════════════════════════════════════════════════════════╝"

# Clean up plan file
rm -f tfplan

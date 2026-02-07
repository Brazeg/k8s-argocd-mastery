#!/bin/bash
set -e

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║     Manual Setup (without asdf)                                 ║"
echo "║     Use this if you prefer not to use asdf                      ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

GREEN='\033[0;32m'
NC='\033[0m'
print_status() { echo -e "${GREEN}[✓]${NC} $1"; }

# Check Docker
echo "Checking Docker..."
if ! docker info > /dev/null 2>&1; then
    echo "ERROR: Docker is not running!"
    exit 1
fi
print_status "Docker is running"

# Install kubectl
echo "Installing kubectl..."
if ! command -v kubectl &> /dev/null; then
    curl -LO "https://dl.k8s.io/release/v1.29.0/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
fi
print_status "kubectl installed"

# Install kind
echo "Installing kind..."
if ! command -v kind &> /dev/null; then
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
    chmod +x ./kind
    sudo mv ./kind /usr/local/bin/kind
fi
print_status "kind installed"

# Install helm
echo "Installing helm..."
if ! command -v helm &> /dev/null; then
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi
print_status "helm installed"

# Install terraform
echo "Installing terraform..."
if ! command -v terraform &> /dev/null; then
    sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
    wget -O- https://apt.releases.hashicorp.com/gpg | \
        gpg --dearmor | \
        sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
        https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
        sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update && sudo apt-get install -y terraform
fi
print_status "terraform installed"

# Install argocd CLI
echo "Installing argocd CLI..."
if ! command -v argocd &> /dev/null; then
    curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/download/v2.10.0/argocd-linux-amd64
    chmod +x argocd
    sudo mv argocd /usr/local/bin/
fi
print_status "argocd CLI installed"

# Install k9s
echo "Installing k9s..."
if ! command -v k9s &> /dev/null; then
    curl -sS https://webinstall.dev/k9s | bash
    export PATH="$HOME/.local/bin:$PATH"
fi
print_status "k9s installed"

# Install yq
echo "Installing yq..."
if ! command -v yq &> /dev/null; then
    sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/v4.40.5/yq_linux_amd64
    sudo chmod +x /usr/local/bin/yq
fi
print_status "yq installed"

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  ✓ Manual setup complete!                                      ║"
echo "║  Next: ./scripts/create-cluster.sh                              ║"
echo "╚════════════════════════════════════════════════════════════════╝"

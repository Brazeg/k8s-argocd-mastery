#!/bin/bash
set -e

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║     Destroying Infrastructure with Terraform                    ║"
echo "╚════════════════════════════════════════════════════════════════╝"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(dirname "$SCRIPT_DIR")"
TERRAFORM_DIR="$LAB_DIR/terraform"

cd "$TERRAFORM_DIR"

echo ""
read -p "Are you sure you want to destroy all infrastructure? (yes/no): " confirm

if [ "$confirm" = "yes" ]; then
    terraform destroy -auto-approve
    rm -f kubeconfig
    echo ""
    echo "✓ Infrastructure destroyed!"
else
    echo "Aborted."
fi

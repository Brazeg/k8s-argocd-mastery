#!/bin/bash
set -e

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║     Kubernetes + ArgoCD Mastery Lab - Setup with asdf          ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_status() { echo -e "${GREEN}[✓]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
print_error() { echo -e "${RED}[✗]${NC} $1"; }

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(dirname "$SCRIPT_DIR")"

# ═══════════════════════════════════════════════════════════════
# Step 1: Check Docker
# ═══════════════════════════════════════════════════════════════
echo "═══════════════════════════════════════════════════════════════"
echo "Step 1: Checking Docker..."
echo "═══════════════════════════════════════════════════════════════"

if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed!"
    echo ""
    echo "Please install Docker Desktop for Windows and enable WSL2 integration."
    exit 1
fi

if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running!"
    echo ""
    echo "Please:"
    echo "1. Start Docker Desktop on Windows"
    echo "2. Go to Settings → Resources → WSL Integration"
    echo "3. Enable integration for your WSL distro"
    echo "4. Run this script again"
    exit 1
fi
print_status "Docker is running"
echo ""

# ═══════════════════════════════════════════════════════════════
# Step 2: Install/Check asdf
# ═══════════════════════════════════════════════════════════════
echo "═══════════════════════════════════════════════════════════════"
echo "Step 2: Setting up asdf..."
echo "═══════════════════════════════════════════════════════════════"

install_asdf() {
    echo "Installing asdf..."
    
    # Install dependencies
    sudo apt-get update
    sudo apt-get install -y curl git
    
    # Clone asdf
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0
    
    # Add to shell config
    SHELL_CONFIG=""
    if [ -f ~/.bashrc ]; then
        SHELL_CONFIG=~/.bashrc
    elif [ -f ~/.zshrc ]; then
        SHELL_CONFIG=~/.zshrc
    fi
    
    if [ -n "$SHELL_CONFIG" ]; then
        if ! grep -q "asdf.sh" "$SHELL_CONFIG"; then
            echo '' >> "$SHELL_CONFIG"
            echo '# asdf version manager' >> "$SHELL_CONFIG"
            echo '. "$HOME/.asdf/asdf.sh"' >> "$SHELL_CONFIG"
            echo '. "$HOME/.asdf/completions/asdf.bash"' >> "$SHELL_CONFIG"
        fi
    fi
    
    # Source asdf for current session
    . "$HOME/.asdf/asdf.sh"
    
    print_status "asdf installed"
}

# Check if asdf is installed
if [ -f "$HOME/.asdf/asdf.sh" ]; then
    . "$HOME/.asdf/asdf.sh"
    print_status "asdf is already installed ($(asdf version))"
elif command -v asdf &> /dev/null; then
    print_status "asdf is already installed ($(asdf version))"
else
    install_asdf
fi

# Ensure asdf is available
if ! command -v asdf &> /dev/null; then
    . "$HOME/.asdf/asdf.sh"
fi

echo ""

# ═══════════════════════════════════════════════════════════════
# Step 3: Add asdf plugins
# ═══════════════════════════════════════════════════════════════
echo "═══════════════════════════════════════════════════════════════"
echo "Step 3: Adding asdf plugins..."
echo "═══════════════════════════════════════════════════════════════"

add_plugin() {
    local plugin=$1
    local url=$2
    
    if asdf plugin list 2>/dev/null | grep -q "^${plugin}$"; then
        print_status "Plugin '$plugin' already added"
    else
        echo "Adding plugin: $plugin..."
        if [ -n "$url" ]; then
            asdf plugin add "$plugin" "$url"
        else
            asdf plugin add "$plugin"
        fi
        print_status "Plugin '$plugin' added"
    fi
}

# Add all required plugins
add_plugin "kubectl" "https://github.com/asdf-community/asdf-kubectl.git"
add_plugin "kind" "https://github.com/johnlayton/asdf-kind.git"
add_plugin "helm" "https://github.com/Antiarchitect/asdf-helm.git"
add_plugin "terraform" "https://github.com/asdf-community/asdf-hashicorp.git"
add_plugin "argocd" "https://github.com/beardix/asdf-argocd.git"
add_plugin "k9s" "https://github.com/looztra/asdf-k9s.git"
add_plugin "yq" "https://github.com/sudermanjr/asdf-yq.git"

echo ""

# ═══════════════════════════════════════════════════════════════
# Step 4: Install tools from .tool-versions
# ═══════════════════════════════════════════════════════════════
echo "═══════════════════════════════════════════════════════════════"
echo "Step 4: Installing tools from .tool-versions..."
echo "═══════════════════════════════════════════════════════════════"

cd "$LAB_DIR"

if [ ! -f ".tool-versions" ]; then
    print_error ".tool-versions file not found in $LAB_DIR"
    exit 1
fi

echo "Installing tools (this may take a few minutes)..."
echo ""

# Install each tool
while IFS=' ' read -r tool version; do
    # Skip empty lines and comments
    [[ -z "$tool" || "$tool" =~ ^# ]] && continue
    
    echo "Installing $tool $version..."
    if asdf install "$tool" "$version" 2>&1 | tail -1; then
        print_status "$tool $version installed"
    else
        print_warning "$tool $version may already be installed"
    fi
done < .tool-versions

echo ""

# ═══════════════════════════════════════════════════════════════
# Step 5: Verify installations
# ═══════════════════════════════════════════════════════════════
echo "═══════════════════════════════════════════════════════════════"
echo "Step 5: Verifying installations..."
echo "═══════════════════════════════════════════════════════════════"

cd "$LAB_DIR"

echo ""
echo "Tool versions (from .tool-versions):"
echo "─────────────────────────────────────"

verify_tool() {
    local tool=$1
    local cmd=$2
    
    if command -v "$tool" &> /dev/null; then
        version=$($cmd 2>/dev/null | head -1)
        print_status "$tool: $version"
    else
        print_error "$tool: NOT FOUND"
    fi
}

verify_tool "kubectl" "kubectl version --client --short"
verify_tool "kind" "kind version"
verify_tool "helm" "helm version --short"
verify_tool "terraform" "terraform version"
verify_tool "argocd" "argocd version --client --short"
verify_tool "k9s" "k9s version --short"
verify_tool "yq" "yq --version"

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  ✓ Setup complete!                                             ║"
echo "║                                                                 ║"
echo "║  IMPORTANT: Run this to load asdf in your current shell:       ║"
echo "║                                                                 ║"
echo "║    source ~/.asdf/asdf.sh                                       ║"
echo "║                                                                 ║"
echo "║  Or open a new terminal.                                        ║"
echo "║                                                                 ║"
echo "║  Next: ./scripts/create-cluster.sh                              ║"
echo "╚════════════════════════════════════════════════════════════════╝"

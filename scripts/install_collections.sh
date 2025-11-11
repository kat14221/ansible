#!/usr/bin/env bash
# Script to install Ansible collections from local cache or Galaxy
# Usage: bash scripts/install_collections.sh [VENV_PATH]

set -euo pipefail

VENV_PATH=${1:-"$HOME/ansible-venv"}
COLLECTIONS_DIR="${VENV_PATH}/collections"

echo "Installing Ansible collections..."

# Activate venv
source "${VENV_PATH}/bin/activate"

# Create collections directory
mkdir -p "${COLLECTIONS_DIR}/ansible_collections"

echo "[1/3] Attempting to install from Galaxy..."
if ansible-galaxy collection install \
    community.vmware \
    community.general \
    --collections-path "${COLLECTIONS_DIR}" \
    --force 2>&1 | grep -v "HTTPConnection"; then
    echo "✓ Collections installed successfully from Galaxy"
else
    echo "⚠ Galaxy server unavailable, trying alternative method..."
    
    # Download from GitHub if Galaxy fails
    echo "[2/3] Downloading collections from GitHub..."
    mkdir -p "${COLLECTIONS_DIR}/ansible_collections/community"
    
    # Try to download community.vmware
    if command -v git &> /dev/null; then
        cd "${COLLECTIONS_DIR}/ansible_collections/community"
        git clone --depth 1 https://github.com/ansible-collections/community.vmware.git 2>/dev/null || \
            echo "Note: Could not clone community.vmware from GitHub"
        cd - > /dev/null
    else
        echo "Git not found, skipping GitHub download"
    fi
fi

echo "[3/3] Verifying Ansible collections..."
ansible-galaxy collection list || echo "Could not list collections"

deactivate || true
echo "Done!"

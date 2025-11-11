#!/usr/bin/env bash
set -euo pipefail

# Setup script for VM Control Python virtual environment and Ansible + pyvmomi
# Usage: sudo bash scripts/setup_vm_control_env.sh [VENV_PATH]
# Example: sudo bash scripts/setup_vm_control_env.sh /home/ansible/venv

VENV_PATH=${1:-"$HOME/ansible-venv"}

echo "[1/8] Running apt update and installing OS packages (requires sudo)..."
apt update
apt install -y python3-venv python3-pip build-essential libssl-dev libffi-dev python3-dev gcc wget curl git

echo "[2/8] Creating virtual environment at: ${VENV_PATH}"
mkdir -p "$(dirname "$VENV_PATH")"
python3 -m venv "$VENV_PATH"

echo "[3/8] Activating virtualenv and upgrading pip/setuptools/wheel"
source "${VENV_PATH}/bin/activate"
python -m pip install --upgrade pip setuptools wheel

# Create ansible.cfg to skip SSL verification for Galaxy
mkdir -p ~/.ansible
cat > ~/.ansible/galaxy-ssl-skip.cfg << 'EOF'
[defaults]
host_key_checking = False
verify_certs = False

[galaxy]
server = https://galaxy.ansible.com
verify_certs = False
EOF

echo "[4/8] Installing Python requirements (Ansible, pyvmomi pinned versions)"
REQ_FILE="$(dirname "$0")/requirements-vmware.txt"
pip install -r "$REQ_FILE"

echo "[5/8] Installing Ansible collections required (community.vmware, community.general)"
export PATH="$VENV_PATH/bin:$PATH"
export ANSIBLE_CONFIG="$HOME/.ansible/ansible.cfg"

# Try to install collections with multiple fallback options
echo "Attempting to install collections..."
if ansible-galaxy collection install community.vmware community.general --force 2>/dev/null; then
    echo "✓ Collections installed successfully"
else
    echo "⚠ Could not install collections from Galaxy, they may be missing"
    echo "  You can install them later manually with:"
    echo "  ansible-galaxy collection install community.vmware community.general"
fi

echo "[6/8] Verifying installation"
which ansible-playbook || true
ansible-playbook --version || true
python - <<'PY'
try:
    import pyVmomi
    print('✓ pyvmomi imported successfully')
except Exception as e:
    print(f'✗ Error importing pyvmomi: {e}')
PY

echo "[7/8] Ensure evidence log dir exists (optional)"
mkdir -p "$(pwd)/evidence/logs"
chown -R $(whoami) "$(pwd)/evidence" || true

echo "[8/8] Done. To use the environment run:"
echo "  source ${VENV_PATH}/bin/activate"
echo "  ansible-playbook playbooks/bootstrap_complete.yml -i inventory/hosts.yml -u root --ask-vault-pass"

deactivate || true

exit 0

#!/usr/bin/env bash
# Bootstrap script para VM de control Ansible
# Instala dependencias, Python, Ansible, collections y prepara evidencias

set -euo pipefail

echo "=========================================="
echo "🚀 Bootstrap de VM de Control Ansible"
echo "=========================================="

# Variables de entorno para instalación no interactiva
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

# 1. Actualizar sistema base
echo "[1/6] Actualizando sistema base..."
sudo apt-get update -qq
sudo apt-get upgrade -y -qq

# 2. Instalar paquetes esenciales
echo "[2/6] Instalando paquetes esenciales..."
sudo apt-get install -y --no-install-recommends \
  python3 \
  python3-pip \
  python3-venv \
  python3-full \
  ansible \
  git \
  sshpass \
  build-essential \
  libssl-dev \
  libffi-dev \
  ca-certificates \
  curl \
  wget \
  jq \
  vim \
  net-tools \
  iputils-ping \
  python3-netaddr \
  python3-jinja2 \
  python3-passlib \
  python3-requests \
  python3-cryptography \
  python3-jmespath

# 3. Actualizar CA certificates
echo "[3/6] Actualizando certificados..."
sudo update-ca-certificates 2>/dev/null || true

# 4. Instalar dependencias Python
echo "[4/6] Instalando dependencias Python..."
if [[ -f requirements-pip.txt ]]; then
  # Usar --break-system-packages para Debian 12/Ubuntu 23.04+
  # Solo instala paquetes que no están disponibles vía apt
  echo "Instalando pyvmomi (no disponible en apt)..."
  pip3 install --break-system-packages pyvmomi>=8.0.0.1 || \
    pip3 install --user pyvmomi>=8.0.0.1 || \
    python3 -m pip install --break-system-packages pyvmomi>=8.0.0.1
  
  echo "✅ Dependencias Python instaladas (pyvmomi)"
  echo "✅ Otras dependencias ya instaladas vía apt"
else
  echo "⚠️  requirements-pip.txt no encontrado, saltando instalación pip"
fi

# 5. Instalar Ansible Collections
echo "[5/6] Instalando Ansible Collections..."
if [[ -f requirements.yml ]]; then
  ansible-galaxy collection install -r requirements.yml --force
  echo "✅ Collections instaladas desde requirements.yml"
else
  echo "⚠️  requirements.yml no encontrado, saltando instalación de collections"
fi

# 6. Crear estructura de evidencias
echo "[6/6] Creando estructura de directorios..."
mkdir -p evidence/{configs,pings,pcaps,services,reports,logs}
mkdir -p group_vars/all

# Permisos
chmod +x bootstrap_control_vm.sh 2>/dev/null || true

echo ""
echo "=========================================="
echo "✅ Bootstrap completado exitosamente"
echo "=========================================="
echo ""
echo "Próximos pasos:"
echo "  1. Ejecutar: ansible-playbook playbooks/bootstrap_control.yml"
echo "  2. Crear/editar Vault: ansible-vault create group_vars/all/vault.yml"
echo "  3. Ejecutar playbook principal: ansible-playbook playbooks/site.yml --ask-vault-pass"
echo ""

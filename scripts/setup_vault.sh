#!/usr/bin/env bash
# Script interactivo para configurar Ansible Vault
# Automatiza la creación y cifrado del vault con credenciales

set -euo pipefail

echo "=========================================="
echo "🔐 Configuración Automática de Vault"
echo "=========================================="
echo ""

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Verificar que estamos en el directorio correcto
if [ ! -f "group_vars/all/vault.yml.template" ]; then
  echo -e "${RED}❌ Error: No se encuentra vault.yml.template${NC}"
  echo "   Ejecuta este script desde el directorio raíz del proyecto ansible/"
  exit 1
fi

echo -e "${BLUE}Este script te guiará para configurar el Vault de Ansible.${NC}"
echo ""
echo "Se te pedirán las siguientes credenciales:"
echo "  1. Credenciales de ESXi/vCenter"
echo "  2. Credenciales de dispositivos Cisco IOS"
echo "  3. Contraseña para cifrar el Vault"
echo ""
read -p "¿Deseas continuar? (s/n): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[SsYy]$ ]]; then
  echo "Cancelado por el usuario."
  exit 0
fi

echo ""
echo "=========================================="
echo "📋 Paso 1: Credenciales de ESXi/vCenter"
echo "=========================================="
echo ""

read -p "IP de ESXi/vCenter [172.17.25.1]: " VCENTER_HOST
VCENTER_HOST=${VCENTER_HOST:-172.17.25.1}

read -p "Usuario de vCenter [root]: " VCENTER_USER
VCENTER_USER=${VCENTER_USER:-root}

echo -n "Contraseña de vCenter: "
read -s VCENTER_PASS
echo ""

if [ -z "$VCENTER_PASS" ]; then
  echo -e "${RED}❌ Error: La contraseña no puede estar vacía${NC}"
  exit 1
fi

echo ""
echo "=========================================="
echo "📋 Paso 2: Credenciales de Cisco IOS"
echo "=========================================="
echo ""
echo -e "${YELLOW}ℹ️  Si tu router NO tiene credenciales configuradas aún,${NC}"
echo -e "${YELLOW}   puedes dejar esto vacío y configurarlo después.${NC}"
echo ""

read -p "Usuario de Cisco IOS [admin] (Enter para omitir): " CISCO_USER
CISCO_USER=${CISCO_USER:-admin}

echo -n "Contraseña de Cisco IOS (Enter para omitir): "
read -s CISCO_PASS
echo ""

if [ -z "$CISCO_PASS" ]; then
  echo -e "${YELLOW}⚠️  Credenciales Cisco vacías - Deberás configurarlas después${NC}"
  echo -e "${YELLOW}   Para configurar el router físico, conéctate por consola y ejecuta:${NC}"
  echo -e "${YELLOW}   1. enable${NC}"
  echo -e "${YELLOW}   2. configure terminal${NC}"
  echo -e "${YELLOW}   3. username admin privilege 15 secret tu_password${NC}"
  echo -e "${YELLOW}   4. ip ssh version 2${NC}"
  echo -e "${YELLOW}   5. line vty 0 4 → login local → transport input ssh${NC}"
  echo ""
  CISCO_USER="admin"
  CISCO_PASS="changeme"  # Placeholder temporal
fi

echo ""
echo "=========================================="
echo "📋 Paso 3: Clave SSH Pública"
echo "=========================================="
echo ""

SSH_KEY_PATH="$HOME/.ssh/id_rsa_ansible.pub"

if [ -f "$SSH_KEY_PATH" ]; then
  SSH_PUBLIC_KEY=$(cat "$SSH_KEY_PATH")
  echo -e "${GREEN}✅ Clave SSH encontrada:${NC}"
  echo "   $SSH_PUBLIC_KEY"
else
  echo -e "${YELLOW}⚠️  No se encontró clave SSH en $SSH_KEY_PATH${NC}"
  echo "   Se dejará vacío en el Vault (puedes añadirla después)"
  SSH_PUBLIC_KEY=""
fi

echo ""
echo "=========================================="
echo "📋 Paso 4: Credenciales FTP (opcional)"
echo "=========================================="
echo ""

read -p "Usuario FTP [ftpuser]: " FTP_USER
FTP_USER=${FTP_USER:-ftpuser}

echo -n "Contraseña FTP (Enter para generar aleatoria): "
read -s FTP_PASS
echo ""

if [ -z "$FTP_PASS" ]; then
  FTP_PASS=$(openssl rand -base64 12 | tr -d '/+=' | cut -c1-12)
  echo -e "${BLUE}ℹ️  Contraseña FTP generada: $FTP_PASS${NC}"
fi

echo ""
echo "=========================================="
echo "📋 Paso 5: Contraseña del Vault"
echo "=========================================="
echo ""
echo -e "${YELLOW}Esta contraseña cifrará todas las credenciales.${NC}"
echo -e "${YELLOW}¡No la olvides! La necesitarás para ejecutar playbooks.${NC}"
echo ""

while true; do
  echo -n "Contraseña del Vault (mínimo 8 caracteres): "
  read -s VAULT_PASS
  echo ""
  
  if [ ${#VAULT_PASS} -lt 8 ]; then
    echo -e "${RED}❌ Error: La contraseña debe tener al menos 8 caracteres${NC}"
    continue
  fi
  
  echo -n "Confirmar contraseña del Vault: "
  read -s VAULT_PASS_CONFIRM
  echo ""
  
  if [ "$VAULT_PASS" != "$VAULT_PASS_CONFIRM" ]; then
    echo -e "${RED}❌ Error: Las contraseñas no coinciden${NC}"
    continue
  fi
  
  break
done

echo ""
echo "=========================================="
echo "🔨 Creando Vault..."
echo "=========================================="
echo ""

# Crear archivo vault.yml desde template
VAULT_FILE="group_vars/all/vault.yml"

cat > "$VAULT_FILE" << EOF
---
# Ansible Vault - Credenciales cifradas
# Generado automáticamente el $(date '+%Y-%m-%d %H:%M:%S')

# ==========================================
# CREDENCIALES ESXi/vCenter
# ==========================================
vault_vcenter_hostname: "$VCENTER_HOST"
vault_vcenter_username: "$VCENTER_USER"
vault_vcenter_password: "$VCENTER_PASS"

# ==========================================
# CREDENCIALES CISCO IOS
# ==========================================
vault_cisco_user: "$CISCO_USER"
vault_cisco_password: "$CISCO_PASS"
vault_cisco_enable_password: "$CISCO_PASS"

# ==========================================
# CLAVE SSH PÚBLICA
# ==========================================
vault_ansible_ssh_public_key: "$SSH_PUBLIC_KEY"

# ==========================================
# CREDENCIALES FTP/HTTP
# ==========================================
vault_ftp_user: "$FTP_USER"
vault_ftp_password: "$FTP_PASS"

# ==========================================
# OTRAS CREDENCIALES
# ==========================================
# Añadir aquí más credenciales según sea necesario
EOF

echo -e "${GREEN}✅ Archivo vault.yml creado${NC}"

# Guardar contraseña del Vault en .vault_pass
echo "$VAULT_PASS" > .vault_pass
chmod 600 .vault_pass
echo -e "${GREEN}✅ Contraseña guardada en .vault_pass${NC}"

# Cifrar el Vault
echo ""
echo "Cifrando vault.yml con Ansible Vault..."
ansible-vault encrypt "$VAULT_FILE" --vault-id default@.vault_pass

if [ $? -eq 0 ]; then
  echo -e "${GREEN}✅ Vault cifrado exitosamente${NC}"
else
  echo -e "${RED}❌ Error al cifrar el Vault${NC}"
  exit 1
fi

echo ""
echo "=========================================="
echo "✅ Configuración Completada"
echo "=========================================="
echo ""
echo -e "${GREEN}El Vault ha sido configurado y cifrado correctamente.${NC}"
echo ""
echo "📁 Archivos creados:"
echo "   ✅ group_vars/all/vault.yml (cifrado)"
echo "   ✅ .vault_pass (no commitear a Git)"
echo ""
echo "📋 Credenciales configuradas:"
echo "   • ESXi/vCenter: $VCENTER_USER@$VCENTER_HOST"
echo "   • Cisco IOS: $CISCO_USER"
echo "   • FTP: $FTP_USER"
if [ -n "$SSH_PUBLIC_KEY" ]; then
  echo "   • Clave SSH: Configurada"
else
  echo "   • Clave SSH: No configurada (añadir después)"
fi
echo ""
echo "⚠️  IMPORTANTE:"
echo "   • NO commitear .vault_pass a Git (ya está en .gitignore)"
echo "   • Guarda la contraseña del Vault en un lugar seguro"
echo "   • Para ver el Vault: ansible-vault view group_vars/all/vault.yml"
echo "   • Para editar el Vault: ansible-vault edit group_vars/all/vault.yml"
echo ""
echo "🚀 Próximos pasos:"
echo "   1. Copiar clave SSH a hosts remotos (cuando estén listos)"
echo "   2. Actualizar IPs en inventory/hosts.yml"
echo "   3. Ejecutar: ansible-playbook playbooks/site.yml"
echo ""
echo "=========================================="

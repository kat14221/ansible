#!/bin/bash
# Script de gestión de Ansible Vault

set -euo pipefail

VAULT_FILE="group_vars/all/vault.yml"
VAULT_TEMPLATE="group_vars/all/vault.yml.template"

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=========================================="
echo -e "🔐 Gestión de Ansible Vault"
echo -e "==========================================${NC}"

case "${1:-help}" in
  create)
    echo -e "${YELLOW}Creando vault inicial...${NC}"
    
    if [ -f "$VAULT_FILE" ]; then
      echo -e "${RED}⚠️  Ya existe un vault.yml${NC}"
      read -p "¿Deseas recrearlo? (s/n): " -n 1 -r
      echo ""
      if [[ ! $REPLY =~ ^[SsYy]$ ]]; then
        echo "Operación cancelada."
        exit 0
      fi
      rm -f "$VAULT_FILE" .vault_pass
    fi
    
    if [ ! -f "$VAULT_TEMPLATE" ]; then
      echo -e "${RED}❌ No se encuentra $VAULT_TEMPLATE${NC}"
      exit 1
    fi
    
    # Copiar template
    cp "$VAULT_TEMPLATE" "$VAULT_FILE"
    
    echo ""
    echo -e "${BLUE}📝 Configuración de credenciales:${NC}"
    echo ""
    
    # Solicitar credenciales
    read -p "IP de ESXi/vCenter [172.17.25.1]: " vcenter_ip
    vcenter_ip=${vcenter_ip:-172.17.25.1}
    
    read -p "Usuario de vCenter [root]: " vcenter_user
    vcenter_user=${vcenter_user:-root}
    
    read -s -p "Contraseña de vCenter: " vcenter_pass
    echo ""
    
    read -p "Usuario de Cisco IOS [ansible]: " cisco_user
    cisco_user=${cisco_user:-ansible}
    
    read -s -p "Contraseña de Cisco IOS: " cisco_pass
    echo ""
    
    read -s -p "Contraseña del Vault (mínimo 8 caracteres): " vault_pass
    echo ""
    
    read -s -p "Confirmar contraseña del Vault: " vault_pass_confirm
    echo ""
    
    if [ "$vault_pass" != "$vault_pass_confirm" ]; then
      echo -e "${RED}❌ Las contraseñas no coinciden${NC}"
      rm -f "$VAULT_FILE"
      exit 1
    fi
    
    if [ ${#vault_pass} -lt 8 ]; then
      echo -e "${RED}❌ La contraseña debe tener al menos 8 caracteres${NC}"
      rm -f "$VAULT_FILE"
      exit 1
    fi
    
    # Generar clave SSH si no existe
    if [ ! -f ~/.ssh/id_rsa_ansible ]; then
      echo -e "${YELLOW}🔑 Generando clave SSH...${NC}"
      ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_ansible -N "" -C "ansible@control"
      echo -e "${GREEN}✅ Clave SSH generada en ~/.ssh/id_rsa_ansible${NC}"
    fi
    
    SSH_PUBLIC_KEY=$(cat ~/.ssh/id_rsa_ansible.pub)
    
    # Actualizar vault con credenciales reales
    sed -i "s|vault_vcenter_hostname: \".*\"|vault_vcenter_hostname: \"$vcenter_ip\"|g" "$VAULT_FILE"
    sed -i "s|vault_vcenter_username: \".*\"|vault_vcenter_username: \"$vcenter_user\"|g" "$VAULT_FILE"
    sed -i "s|vault_vcenter_password: \".*\"|vault_vcenter_password: \"$vcenter_pass\"|g" "$VAULT_FILE"
    sed -i "s|vault_cisco_user: \".*\"|vault_cisco_user: \"$cisco_user\"|g" "$VAULT_FILE"
    sed -i "s|vault_cisco_password: \".*\"|vault_cisco_password: \"$cisco_pass\"|g" "$VAULT_FILE"
    sed -i "s|vault_cisco_enable_secret: \".*\"|vault_cisco_enable_secret: \"$cisco_pass\"|g" "$VAULT_FILE"
    
    # Actualizar clave SSH
    sed -i "/vault_ansible_ssh_public_key:/,/# REEMPLAZAR/c\\
vault_ansible_ssh_public_key: |\\
  $SSH_PUBLIC_KEY" "$VAULT_FILE"
    
    echo -e "${YELLOW}🔒 Cifrando vault...${NC}"
    # Crear primero el archivo de contraseña para que ansible.cfg lo encuentre
    echo "$vault_pass" > .vault_pass
    chmod 600 .vault_pass
    
    # Ahora cifrar. Ansible usará .vault_pass automáticamente.
    ansible-vault encrypt "$VAULT_FILE"
    
    echo ""
    echo -e "${GREEN}✅ Vault creado y cifrado exitosamente${NC}"
    echo -e "${GREEN}✅ Contraseña guardada en .vault_pass${NC}"
    echo -e "${GREEN}✅ Clave SSH generada: ~/.ssh/id_rsa_ansible${NC}"
    ;;
    
  edit)
    echo -e "${YELLOW}Editando vault...${NC}"
    if [ ! -f "$VAULT_FILE" ]; then
      echo -e "${RED}❌ No existe $VAULT_FILE${NC}"
      echo "Ejecuta: $0 create"
      exit 1
    fi
    ansible-vault edit "$VAULT_FILE"
    ;;
    
  view)
    echo -e "${YELLOW}Visualizando vault...${NC}"
    if [ ! -f "$VAULT_FILE" ]; then
      echo -e "${RED}❌ No existe $VAULT_FILE${NC}"
      exit 1
    fi
    ansible-vault view "$VAULT_FILE"
    ;;
    
  rekey)
    echo -e "${YELLOW}Cambiando password del vault...${NC}"
    if [ ! -f "$VAULT_FILE" ]; then
      echo -e "${RED}❌ No existe $VAULT_FILE${NC}"
      exit 1
    fi
    ansible-vault rekey "$VAULT_FILE"
    read -s -p "Nueva contraseña para .vault_pass: " new_pass
    echo ""
    echo "$new_pass" > .vault_pass
    chmod 600 .vault_pass
    echo -e "${GREEN}✅ Password actualizado${NC}"
    ;;
    
  validate)
    echo -e "${YELLOW}Validando vault...${NC}"
    if [ ! -f "$VAULT_FILE" ]; then
      echo -e "${RED}❌ No existe $VAULT_FILE${NC}"
      exit 1
    fi
    if ansible-vault view "$VAULT_FILE" > /dev/null 2>&1; then
      echo -e "${GREEN}✅ Vault válido${NC}"
    else
      echo -e "${RED}❌ Vault inválido o password incorrecto${NC}"
      exit 1
    fi
    ;;
    
  backup)
    BACKUP_DIR="backups/vault"
    mkdir -p "$BACKUP_DIR"
    BACKUP_FILE="$BACKUP_DIR/vault_$(date +%Y%m%d_%H%M%S).yml"
    if [ -f "$VAULT_FILE" ]; then
      cp "$VAULT_FILE" "$BACKUP_FILE"
      echo -e "${GREEN}✅ Backup creado: $BACKUP_FILE${NC}"
    else
      echo -e "${RED}❌ No existe $VAULT_FILE para hacer backup${NC}"
      exit 1
    fi
    ;;
    
  *)
    echo -e "${BLUE}Uso: $0 {create|edit|view|rekey|validate|backup}${NC}"
    echo ""
    echo "Comandos:"
    echo "  create   - Crear vault inicial desde template"
    echo "  edit     - Editar vault existente"
    echo "  view     - Ver contenido del vault"
    echo "  rekey    - Cambiar password del vault"
    echo "  validate - Validar vault"
    echo "  backup   - Crear backup del vault"
    exit 1
    ;;
esac
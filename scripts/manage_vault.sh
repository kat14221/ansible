#!/bin/bash
# Script de gestión de Ansible Vault en español

set -euo pipefail

VAULT_FILE="group_vars/all/vault.yml"
VAULT_TEMPLATE="group_vars/all/vault.yml.template"

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=============================================="
echo -e "🔐 Gestión de Ansible Vault (en español)"
echo -e "==============================================${NC}"

case "${1:-help}" in
  create)
    echo -e "${YELLOW}Creando el vault inicial...${NC}"
    
    if [ -f "$VAULT_FILE" ]; then
      echo -e "${RED}⚠️  ¡Atención! Ya existe un archivo vault.yml.${NC}"
      read -p "¿Deseas borrarlo y crear uno nuevo? (s/n): " -n 1 -r
      echo ""
      if [[ ! $REPLY =~ ^[SsYy]$ ]]; then
        echo "Operación cancelada."
        exit 0
      fi
      rm -f "$VAULT_FILE" .vault_pass
    fi
    
    if [ ! -f "$VAULT_TEMPLATE" ]; then
      echo -e "${RED}❌ Error: No se encuentra la plantilla $VAULT_TEMPLATE.${NC}"
      exit 1
    fi
    
    # Copiar template
    cp "$VAULT_TEMPLATE" "$VAULT_FILE"
    
    echo ""
    echo -e "${BLUE}📝 Por favor, introduce las credenciales:${NC}"
    echo ""
    
    # Solicitar credenciales
    read -p "Introduce la IP de tu ESXi/vCenter [172.17.25.1]: " vcenter_ip
    vcenter_ip=${vcenter_ip:-172.17.25.1}
    
    read -p "Introduce el usuario de vCenter [root]: " vcenter_user
    vcenter_user=${vcenter_user:-root}
    
    read -s -p "Introduce la contraseña de vCenter: " vcenter_pass
    echo ""
    
    read -p "Introduce el usuario para dispositivos Cisco IOS [ansible]: " cisco_user
    cisco_user=${cisco_user:-ansible}
    
    read -s -p "Introduce la contraseña para dispositivos Cisco IOS: " cisco_pass
    echo ""
    
    read -s -p "Crea una contraseña para el Vault (mínimo 8 caracteres): " vault_pass
    echo ""
    
    read -s -p "Confirma la contraseña del Vault: " vault_pass_confirm
    echo ""
    
    if [ "$vault_pass" != "$vault_pass_confirm" ]; then
      echo -e "${RED}❌ Error: Las contraseñas no coinciden.${NC}"
      rm -f "$VAULT_FILE"
      exit 1
    fi
    
    if [ ${#vault_pass} -lt 8 ]; then
      echo -e "${RED}❌ Error: La contraseña debe tener al menos 8 caracteres.${NC}"
      rm -f "$VAULT_FILE"
      exit 1
    fi
    
    # Generar clave SSH si no existe
    if [ ! -f ~/.ssh/id_rsa_ansible ]; then
      echo -e "${YELLOW}🔑 No se encontró una clave SSH. Generando una nueva...${NC}"
      ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_ansible -N "" -C "ansible@control"
      echo -e "${GREEN}✅ Clave SSH generada exitosamente en ~/.ssh/id_rsa_ansible${NC}"
    fi
    
    SSH_PUBLIC_KEY=$(cat ~/.ssh/id_rsa_ansible.pub)
    
    # Actualizar vault con credenciales reales (usando | como delimitador para evitar conflictos con /)
    sed -i "s|vault_vcenter_hostname: \".*\"|vault_vcenter_hostname: \"$vcenter_ip\"|g" "$VAULT_FILE"
    sed -i "s|vault_vcenter_username: \".*\"|vault_vcenter_username: \"$vcenter_user\"|g" "$VAULT_FILE"
    sed -i "s|vault_vcenter_password: \".*\"|vault_vcenter_password: \"$vcenter_pass\"|g" "$VAULT_FILE"
    sed -i "s|vault_cisco_user: \".*\"|vault_cisco_user: \"$cisco_user\"|g" "$VAULT_FILE"
    sed -i "s|vault_cisco_password: \".*\"|vault_cisco_password: \"$cisco_pass\"|g" "$VAULT_FILE"
    sed -i "s|vault_cisco_enable_secret: \".*\"|vault_cisco_enable_secret: \"$cisco_pass\"|g" "$VAULT_FILE"
    sed -i "/^vault_ansible_ssh_public_key:/,/REEMPLAZAR/c\vault_ansible_ssh_public_key: |\n  $SSH_PUBLIC_KEY" "$VAULT_FILE"
    
    echo -e "${YELLOW}🔒 Cifrando el archivo vault...${NC}"
    # Crear primero el archivo de contraseña para que ansible.cfg lo encuentre
    echo "$vault_pass" > .vault_pass
    chmod 600 .vault_pass
    
    # Ahora cifrar. Ansible usará .vault_pass automáticamente.
    ansible-vault encrypt "$VAULT_FILE"
    
    echo ""
    echo -e "${GREEN}✅ ¡Éxito! El Vault ha sido creado y cifrado.${NC}"
    echo -e "${GREEN}✅ La contraseña del Vault se ha guardado en el archivo .vault_pass para tu comodidad.${NC}"
    echo -e "${GREEN}✅ La clave SSH para la automatización está en: ~/.ssh/id_rsa_ansible${NC}"
    ;;
    
  edit)
    echo -e "${YELLOW}Abriendo el vault para editar...${NC}"
    if [ ! -f "$VAULT_FILE" ]; then
      echo -e "${RED}❌ Error: No se encuentra el archivo $VAULT_FILE.${NC}"
      echo "Primero debes crearlo con: $0 create"
      exit 1
    fi
    ansible-vault edit "$VAULT_FILE"
    ;;
    
  view)
    echo -e "${YELLOW}Mostrando el contenido del vault...${NC}"
    if [ ! -f "$VAULT_FILE" ]; then
      echo -e "${RED}❌ Error: No se encuentra el archivo $VAULT_FILE.${NC}"
      exit 1
    fi
    ansible-vault view "$VAULT_FILE"
    ;;
    
  rekey)
    echo -e "${YELLOW}Cambiando la contraseña del vault...${NC}"
    if [ ! -f "$VAULT_FILE" ]; then
      echo -e "${RED}❌ Error: No se encuentra el archivo $VAULT_FILE.${NC}"
      exit 1
    fi
    ansible-vault rekey "$VAULT_FILE"
    read -s -p "Introduce la nueva contraseña para guardarla en .vault_pass: " new_pass
    echo ""
    echo "$new_pass" > .vault_pass
    chmod 600 .vault_pass
    echo -e "${GREEN}✅ Contraseña actualizada correctamente.${NC}"
    ;;
    
  validate)
    echo -e "${YELLOW}Validando la integridad del vault...${NC}"
    if [ ! -f "$VAULT_FILE" ]; then
      echo -e "${RED}❌ Error: No se encuentra el archivo $VAULT_FILE.${NC}"
      exit 1
    fi
    if ansible-vault view "$VAULT_FILE" > /dev/null 2>&1; then
      echo -e "${GREEN}✅ ¡Perfecto! El Vault es válido y la contraseña es correcta.${NC}"
    else
      echo -e "${RED}❌ Error: El Vault es inválido o la contraseña es incorrecta.${NC}"
      exit 1
    fi
    ;;
    
  backup)
    BACKUP_DIR="backups/vault"
    mkdir -p "$BACKUP_DIR"
    BACKUP_FILE="$BACKUP_DIR/vault_$(date +%Y%m%d_%H%M%S).yml"
    if [ -f "$VAULT_FILE" ]; then
      cp "$VAULT_FILE" "$BACKUP_FILE"
      echo -e "${GREEN}✅ Copia de seguridad creada en: $BACKUP_FILE${NC}"
    else
      echo -e "${RED}❌ Error: No se encuentra el archivo $VAULT_FILE para hacer una copia.${NC}"
      exit 1
    fi
    ;;
    
  *)
    echo -e "${BLUE}Uso: $0 {create|edit|view|rekey|validate|backup}${NC}"
    echo ""
    echo "Comandos:"
    echo "  create   - Crea un nuevo vault desde la plantilla."
    echo "  edit     - Edita de forma segura el vault existente."
    echo "  view     - Muestra el contenido descifrado del vault."
    echo "  rekey    - Cambia la contraseña del vault."
    echo "  validate - Comprueba si el vault se puede descifrar con la contraseña actual."
    echo "  backup   - Crea una copia de seguridad del vault."
    exit 1
    ;;
esac
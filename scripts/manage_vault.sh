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
    
    cp "$VAULT_TEMPLATE" "$VAULT_FILE"
    
    echo ""
    echo -e "${YELLOW}📝 Se ha copiado la plantilla. Por favor, revisa y edita el archivo con tus credenciales.${NC}"
    echo "El editor de texto se abrirá ahora..."
    sleep 2
    ${EDITOR:-nano} "$VAULT_FILE"
    
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
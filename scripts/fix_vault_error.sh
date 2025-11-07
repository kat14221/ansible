#!/usr/bin/env bash
# Script para solucionar el error de vault-id en ansible-vault

set -euo pipefail

echo "=========================================="
echo "🔧 Solucionando Error de Vault"
echo "=========================================="
echo ""

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Este script soluciona el error:${NC}"
echo -e "${RED}ERROR! The vault-ids default,default are available to encrypt${NC}"
echo ""

# Verificar si ya existe un vault.yml
if [ -f "group_vars/all/vault.yml" ]; then
  echo -e "${YELLOW}⚠️  Ya existe un vault.yml${NC}"
  
  # Verificar si está cifrado
  if head -1 group_vars/all/vault.yml | grep -q "ANSIBLE_VAULT"; then
    echo -e "${GREEN}✅ El vault ya está cifrado correctamente${NC}"
    echo ""
    echo "Para verificar el contenido:"
    echo "   ansible-vault view group_vars/all/vault.yml"
    echo ""
    echo "Para editar el contenido:"
    echo "   ansible-vault edit group_vars/all/vault.yml"
    exit 0
  else
    echo -e "${YELLOW}⚠️  El vault existe pero no está cifrado${NC}"
    read -p "¿Deseas cifrarlo ahora? (s/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[SsYy]$ ]]; then
      # Verificar si existe .vault_pass
      if [ ! -f ".vault_pass" ]; then
        echo -n "Ingresa la contraseña para el vault: "
        read -s VAULT_PASS
        echo ""
        echo "$VAULT_PASS" > .vault_pass
        chmod 600 .vault_pass
      fi
      
      echo "Cifrando vault existente..."
      ansible-vault encrypt group_vars/all/vault.yml --vault-id default@.vault_pass
      
      if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Vault cifrado exitosamente${NC}"
      else
        echo -e "${RED}❌ Error al cifrar el vault${NC}"
        exit 1
      fi
    fi
  fi
else
  echo -e "${YELLOW}⚠️  No existe vault.yml${NC}"
  echo ""
  echo "Opciones:"
  echo "  1. Ejecutar configuración automática: ./scripts/setup_vault.sh"
  echo "  2. Crear manualmente desde template"
  echo ""
  read -p "¿Ejecutar configuración automática? (s/n): " -n 1 -r
  echo ""
  if [[ $REPLY =~ ^[SsYy]$ ]]; then
    ./scripts/setup_vault.sh
  else
    echo "Para crear manualmente:"
    echo "  1. cp group_vars/all/vault.yml.template group_vars/all/vault.yml"
    echo "  2. vim group_vars/all/vault.yml  # Editar credenciales"
    echo "  3. ansible-vault encrypt group_vars/all/vault.yml --vault-id default@.vault_pass"
  fi
fi

echo ""
echo "=========================================="
echo "✅ Problema Solucionado"
echo "=========================================="
echo ""
echo -e "${GREEN}El vault debería funcionar correctamente ahora.${NC}"
echo ""
echo "Para verificar:"
echo "   ansible-vault view group_vars/all/vault.yml"
echo ""
echo "Para continuar con el proyecto:"
echo "   ansible-playbook playbooks/site.yml -vvv"
echo ""
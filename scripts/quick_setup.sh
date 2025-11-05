#!/usr/bin/env bash
# Script maestro de configuración rápida - Ejecuta todo automáticamente

set -euo pipefail

echo "=========================================="
echo "🚀 Configuración Rápida - Proyecto Ansible"
echo "=========================================="
echo ""

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

echo -e "${BLUE}Este script automatiza toda la configuración:${NC}"
echo "  1. ✅ Bootstrap (ya ejecutado)"
echo "  2. 🔐 Configurar Vault con credenciales"
echo "  3. 🔑 Generar/copiar claves SSH"
echo "  4. 📝 Actualizar inventario"
echo ""

# Verificar que bootstrap ya fue ejecutado
if [ ! -d "evidence/configs" ]; then
  echo -e "${YELLOW}⚠️  Parece que bootstrap aún no se ha ejecutado.${NC}"
  echo ""
  read -p "¿Ejecutar bootstrap ahora? (s/n): " -n 1 -r
  echo ""
  if [[ $REPLY =~ ^[SsYy]$ ]]; then
    echo "Ejecutando bootstrap..."
    ./bootstrap_control_vm.sh
    ansible-playbook playbooks/bootstrap_control.yml
  else
    echo "Por favor ejecuta primero:"
    echo "  ./bootstrap_control_vm.sh"
    echo "  ansible-playbook playbooks/bootstrap_control.yml"
    exit 1
  fi
fi

echo ""
echo "=========================================="
echo "🔐 Paso 1: Configurar Vault"
echo "=========================================="
echo ""

if [ -f "group_vars/all/vault.yml" ]; then
  echo -e "${YELLOW}⚠️  Ya existe un vault.yml${NC}"
  read -p "¿Deseas recrearlo? (s/n): " -n 1 -r
  echo ""
  if [[ $REPLY =~ ^[SsYy]$ ]]; then
    rm -f group_vars/all/vault.yml .vault_pass
    ./scripts/setup_vault.sh
  else
    echo "Manteniendo vault.yml existente"
  fi
else
  ./scripts/setup_vault.sh
fi

echo ""
echo "=========================================="
echo "📝 Paso 2: Actualizar Inventario"
echo "=========================================="
echo ""

echo -e "${YELLOW}Por favor verifica/actualiza las siguientes IPs en inventory/hosts.yml:${NC}"
echo ""
echo "  • Línea 121: IP de gestión del physical-router"
echo "  • Línea 142: IP de gestión del switch-3"
echo "  • Línea 7: IP de ESXi (si es diferente)"
echo ""

read -p "¿Deseas editar el inventario ahora? (s/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[SsYy]$ ]]; then
  ${EDITOR:-vim} inventory/hosts.yml
fi

echo ""
echo "=========================================="
echo "🔑 Paso 3: Copiar Claves SSH"
echo "=========================================="
echo ""

echo -e "${YELLOW}Las claves SSH se copiarán cuando los hosts estén disponibles.${NC}"
echo ""
read -p "¿Los hosts remotos ya están disponibles? (s/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[SsYy]$ ]]; then
  ./scripts/copy_ssh_keys.sh
else
  echo ""
  echo -e "${BLUE}ℹ️  Podrás copiar las claves después con:${NC}"
  echo "   ./scripts/copy_ssh_keys.sh"
fi

echo ""
echo "=========================================="
echo "✅ Configuración Completada"
echo "=========================================="
echo ""
echo -e "${GREEN}Todo está listo para ejecutar el proyecto.${NC}"
echo ""
echo "🚀 Ejecutar proyecto completo:"
echo "   ansible-playbook playbooks/site.yml"
echo ""
echo "🎯 Ejecutar por fases:"
echo "   ansible-playbook playbooks/site.yml --tags network"
echo "   ansible-playbook playbooks/site.yml --tags vm_creation"
echo "   ansible-playbook playbooks/site.yml --tags debian,services"
echo "   ansible-playbook playbooks/site.yml --tags firewall,security"
echo "   ansible-playbook playbooks/site.yml --tags evidence,reports"
echo ""
echo "📊 Generar informes técnicos:"
echo "   ansible-playbook playbooks/generate_reports.yml"
echo ""
echo "🔍 Validar conectividad:"
echo "   ansible-playbook playbooks/validate_connectivity.yml"
echo ""
echo "=========================================="

#!/usr/bin/env bash
# Script para copiar claves SSH a hosts remotos de forma automatizada

set -euo pipefail

echo "=========================================="
echo "🔑 Copiar Claves SSH a Hosts Remotos"
echo "=========================================="
echo ""

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Verificar que existe la clave SSH
SSH_KEY="$HOME/.ssh/id_rsa_ansible.pub"
if [ ! -f "$SSH_KEY" ]; then
  echo -e "${RED}❌ Error: No se encuentra la clave SSH en $SSH_KEY${NC}"
  echo "   Ejecuta: ansible-playbook playbooks/bootstrap_control.yml"
  exit 1
fi

echo -e "${GREEN}✅ Clave SSH encontrada${NC}"
echo ""
cat "$SSH_KEY"
echo ""

# Lista de hosts
declare -A HOSTS=(
  ["debian-router"]="172.17.25.126"
  ["ubuntu-pc"]="2025:db8:101::10"
  ["windows-pc"]="2025:db8:101::11"
)

echo "Se copiará la clave SSH a los siguientes hosts:"
echo ""
for host in "${!HOSTS[@]}"; do
  echo "  • $host (${HOSTS[$host]})"
done
echo ""

read -p "Usuario SSH (generalmente 'ansible'): " SSH_USER
SSH_USER=${SSH_USER:-ansible}

echo ""
echo -e "${YELLOW}Nota: Se te pedirá la contraseña SSH de cada host.${NC}"
echo ""
read -p "¿Deseas continuar? (s/n): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[SsYy]$ ]]; then
  echo "Cancelado."
  exit 0
fi

echo ""
echo "=========================================="
echo "📤 Copiando claves SSH..."
echo "=========================================="
echo ""

SUCCESS=0
FAILED=0

for host in "${!HOSTS[@]}"; do
  IP="${HOSTS[$host]}"
  echo -e "${YELLOW}➡️  Copiando a $host ($IP)...${NC}"
  
  # Intentar copiar la clave
  if ssh-copy-id -i "$SSH_KEY" -o ConnectTimeout=10 "$SSH_USER@$IP" 2>/dev/null; then
    echo -e "${GREEN}✅ $host - Clave copiada exitosamente${NC}"
    ((SUCCESS++))
  else
    echo -e "${RED}❌ $host - Error al copiar (host no disponible o contraseña incorrecta)${NC}"
    ((FAILED++))
  fi
  echo ""
done

echo "=========================================="
echo "📊 Resumen"
echo "=========================================="
echo ""
echo -e "${GREEN}✅ Exitosos: $SUCCESS${NC}"
echo -e "${RED}❌ Fallidos: $FAILED${NC}"
echo ""

if [ $SUCCESS -gt 0 ]; then
  echo "🧪 Probar conexión SSH:"
  for host in "${!HOSTS[@]}"; do
    IP="${HOSTS[$host]}"
    echo "   ssh -i ~/.ssh/id_rsa_ansible $SSH_USER@$IP"
  done
fi

echo ""
echo "=========================================="

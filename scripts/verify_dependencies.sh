#!/usr/bin/env bash
# ============================================================================
# Script de Verificación de Dependencias
# ============================================================================
# Propósito: Verificar que todas las dependencias estén instaladas y con
#            las versiones correctas
#
# Uso: ./scripts/verify_dependencies.sh
#
# Códigos de salida:
#   0 - Todas las dependencias OK
#   1 - Faltan dependencias o versiones incorrectas
# ============================================================================

set -euo pipefail

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

echo "=============================================="
echo "🔍 Verificación de Dependencias Ansible"
echo "=============================================="
echo ""

# Función para verificar comando
check_command() {
  local cmd=$1
  local name=$2
  
  if command -v "$cmd" &> /dev/null; then
    echo -e "${GREEN}✅${NC} $name: $(command -v $cmd)"
    return 0
  else
    echo -e "${RED}❌${NC} $name: NO ENCONTRADO"
    ((ERRORS++))
    return 1
  fi
}

# Función para verificar versión de comando
check_version() {
  local cmd=$1
  local name=$2
  local min_version=$3
  local version_cmd=$4
  
  if command -v "$cmd" &> /dev/null; then
    local version=$(eval "$version_cmd" 2>/dev/null | head -n1)
    echo -e "${GREEN}✅${NC} $name: $version"
    return 0
  else
    echo -e "${RED}❌${NC} $name: NO ENCONTRADO (mínimo: $min_version)"
    ((ERRORS++))
    return 1
  fi
}

# Función para verificar paquete Python
check_python_package() {
  local package=$1
  local name=$2
  local required_version=$3
  
  if python3 -c "import $package" 2>/dev/null; then
    local version=$(python3 -c "import $package; print($package.__version__)" 2>/dev/null || echo "desconocida")
    
    if [[ -n "$required_version" && "$version" != "$required_version" ]]; then
      echo -e "${YELLOW}⚠️${NC}  $name: $version (recomendada: $required_version)"
      ((WARNINGS++))
    else
      echo -e "${GREEN}✅${NC} $name: $version"
    fi
    return 0
  else
    echo -e "${RED}❌${NC} $name: NO ENCONTRADO"
    ((ERRORS++))
    return 1
  fi
}

# Función para verificar collection
check_collection() {
  local collection=$1
  local min_version=$2
  
  if ansible-galaxy collection list 2>/dev/null | grep -q "$collection"; then
    local version=$(ansible-galaxy collection list 2>/dev/null | grep "$collection" | awk '{print $2}')
    echo -e "${GREEN}✅${NC} $collection: $version"
    return 0
  else
    echo -e "${RED}❌${NC} $collection: NO ENCONTRADA (mínimo: $min_version)"
    ((ERRORS++))
    return 1
  fi
}

# 1. Verificar comandos del sistema
echo -e "${BLUE}[1/5]${NC} Comandos del Sistema"
echo "----------------------------------------"
check_command "python3" "Python 3"
check_command "pip3" "pip3"
check_command "ansible" "Ansible"
check_command "ansible-playbook" "ansible-playbook"
check_command "ansible-galaxy" "ansible-galaxy"
check_command "git" "Git"
check_command "ssh" "SSH"
check_command "sshpass" "sshpass"
echo ""

# 2. Verificar versiones
echo -e "${BLUE}[2/5]${NC} Versiones de Software"
echo "----------------------------------------"
check_version "python3" "Python" "3.11" "python3 --version"
check_version "ansible" "Ansible" "2.16" "ansible --version"
check_version "git" "Git" "2.0" "git --version"
echo ""

# 3. Verificar paquetes Python críticos
echo -e "${BLUE}[3/5]${NC} Paquetes Python"
echo "----------------------------------------"
check_python_package "pyVmomi" "pyvmomi" "8.0.3.0.1"
check_python_package "netaddr" "netaddr" ""
check_python_package "jinja2" "Jinja2" ""
check_python_package "passlib" "passlib" ""
check_python_package "requests" "requests" ""
check_python_package "cryptography" "cryptography" ""
check_python_package "jmespath" "jmespath" ""

# Opcional pero recomendado
if python3 -c "import ansible_pylibssh" 2>/dev/null; then
  echo -e "${GREEN}✅${NC} ansible-pylibssh: instalado (mejora rendimiento SSH)"
else
  echo -e "${YELLOW}⚠️${NC}  ansible-pylibssh: NO instalado (opcional, mejora rendimiento)"
  ((WARNINGS++))
fi
echo ""

# 4. Verificar Ansible Collections
echo -e "${BLUE}[4/5]${NC} Ansible Collections"
echo "----------------------------------------"
check_collection "community.vmware" "4.0.0"
check_collection "cisco.ios" "6.0.0"
check_collection "ansible.netcommon" "6.0.0"
check_collection "ansible.posix" "1.5.0"
check_collection "ansible.utils" "3.0.0"
echo ""

# 5. Verificar estructura de directorios
echo -e "${BLUE}[5/5]${NC} Estructura de Directorios"
echo "----------------------------------------"
REQUIRED_DIRS=(
  "evidence/configs"
  "evidence/pings"
  "evidence/pcaps"
  "evidence/services"
  "evidence/reports"
  "evidence/logs"
  "group_vars/all"
  "playbooks"
  "roles"
  "inventory"
)

for dir in "${REQUIRED_DIRS[@]}"; do
  if [ -d "$dir" ]; then
    echo -e "${GREEN}✅${NC} $dir"
  else
    echo -e "${YELLOW}⚠️${NC}  $dir (no existe, se creará automáticamente)"
    ((WARNINGS++))
  fi
done
echo ""

# 6. Verificar archivos de configuración
echo -e "${BLUE}[6/6]${NC} Archivos de Configuración"
echo "----------------------------------------"
REQUIRED_FILES=(
  "ansible.cfg"
  "requirements.yml"
  "requirements.txt"
  "inventory/hosts.yml"
)

for file in "${REQUIRED_FILES[@]}"; do
  if [ -f "$file" ]; then
    echo -e "${GREEN}✅${NC} $file"
  else
    echo -e "${YELLOW}⚠️${NC}  $file (no existe)"
    ((WARNINGS++))
  fi
done
echo ""

# Resumen final
echo "=============================================="
echo "📊 Resumen de Verificación"
echo "=============================================="

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
  echo -e "${GREEN}✅ PERFECTO: Todas las dependencias están correctamente instaladas${NC}"
  echo ""
  echo "🚀 Puedes ejecutar los playbooks:"
  echo "   ansible-playbook playbooks/site.yml"
  exit 0
elif [ $ERRORS -eq 0 ]; then
  echo -e "${YELLOW}⚠️  ADVERTENCIAS: $WARNINGS${NC}"
  echo ""
  echo "El sistema funcionará, pero hay algunas recomendaciones:"
  echo "   ./scripts/bootstrap_control_vm.sh"
  exit 0
else
  echo -e "${RED}❌ ERRORES: $ERRORS${NC}"
  echo -e "${YELLOW}⚠️  ADVERTENCIAS: $WARNINGS${NC}"
  echo ""
  echo "Debes instalar las dependencias faltantes:"
  echo "   ./scripts/bootstrap_control_vm.sh"
  exit 1
fi
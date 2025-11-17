#!/usr/bin/env bash
# ============================================================================
# Bootstrap script para VM de control Ansible
# ============================================================================
# Propósito: Instalar y configurar todas las dependencias necesarias para
#            ejecutar playbooks Ansible con VMware y Cisco
#
# Características:
#   - IDEMPOTENTE: Solo instala lo que falta
#   - VERIFICACIÓN: Comprueba versiones antes de instalar
#   - FEEDBACK: Muestra claramente qué se instala y qué ya existe
#   - ROBUSTO: Maneja errores y ofrece alternativas
#
# Uso: ./scripts/bootstrap_control_vm.sh
#
# Requisitos previos:
#   - Ubuntu 24.04 LTS o Debian 12 (Bookworm)
#   - Acceso a internet
#   - Usuario con permisos sudo
#
# Consultar: BUENAS_PRACTICAS_DEPENDENCIAS.md para más información
# ============================================================================

set -euo pipefail  # Salir en error, variables no definidas, errores en pipes

echo "=========================================="
echo "🚀 Bootstrap de VM de Control Ansible"
echo "=========================================="

# Variables de entorno para instalación no interactiva
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

# Función para verificar si un paquete apt está instalado
check_apt_package() {
  dpkg -l "$1" 2>/dev/null | grep -q "^ii"
}

# Función para verificar si un paquete Python está instalado
check_python_package() {
  python3 -c "import $1" 2>/dev/null
}

# 1. Actualizar sistema base
echo "[1/6] Actualizando sistema base..."
sudo apt-get update -qq
echo "✅ Índice de paquetes actualizado"

# 2. Verificar e instalar paquetes esenciales
echo "[2/6] Verificando paquetes del sistema..."
PACKAGES_TO_INSTALL=()

REQUIRED_PACKAGES=(
  "python3"
  "python3-pip"
  "python3-venv"
  "python3-full"
  "ansible"
  "git"
  "sshpass"
  "build-essential"
  "libssl-dev"
  "libffi-dev"
  "ca-certificates"
  "curl"
  "wget"
  "jq"
  "vim"
  "net-tools"
  "iputils-ping"
  "python3-netaddr"
  "python3-jinja2"
  "python3-passlib"
  "python3-requests"
  "python3-cryptography"
  "python3-jmespath"
  "python3-paramiko"
  "python3-bcrypt"
  "python3-nacl"
)

for pkg in "${REQUIRED_PACKAGES[@]}"; do
  if ! check_apt_package "$pkg"; then
    PACKAGES_TO_INSTALL+=("$pkg")
    echo "  ⬇️  $pkg (faltante)"
  else
    echo "  ✅ $pkg (ya instalado)"
  fi
done

if [ ${#PACKAGES_TO_INSTALL[@]} -gt 0 ]; then
  echo ""
  echo "Instalando ${#PACKAGES_TO_INSTALL[@]} paquetes faltantes..."
  sudo apt-get install -y --no-install-recommends "${PACKAGES_TO_INSTALL[@]}"
  echo "✅ Paquetes instalados"
else
  echo "✅ Todos los paquetes ya están instalados"
fi

# 3. Actualizar CA certificates
echo "[3/6] Actualizando certificados..."
sudo update-ca-certificates 2>/dev/null || true

# 4. Verificar e instalar dependencias Python
echo "[4/6] Verificando dependencias Python..."

# Verificar pyvmomi (no está en apt, necesita pip)
# Versión recomendada: 8.0.3.0.1 (compatible con ESXi 8.0 y evita deprecation warnings)
PYVMOMI_VERSION_REQUIRED="8.0.3.0.1"

if check_python_package "pyVmomi"; then
  PYVMOMI_VERSION=$(python3 -c "import pyVmomi; print(pyVmomi.__version__)" 2>/dev/null || echo "desconocida")
  echo "  ✅ pyvmomi ya instalado (versión: $PYVMOMI_VERSION)"
  
  # Verificar si la versión es antigua y necesita actualización
  if [[ "$PYVMOMI_VERSION" < "8.0.3" ]]; then
    echo "  ⚠️  Versión antigua detectada, actualizando a $PYVMOMI_VERSION_REQUIRED..."
    if pip3 install --break-system-packages --upgrade "pyvmomi==$PYVMOMI_VERSION_REQUIRED" 2>/dev/null; then
      echo "  ✅ pyvmomi actualizado exitosamente"
    elif pip3 install --user --upgrade "pyvmomi==$PYVMOMI_VERSION_REQUIRED" 2>/dev/null; then
      echo "  ✅ pyvmomi actualizado con --user"
    else
      echo "  ⚠️  No se pudo actualizar automáticamente"
    fi
  fi
else
  echo "  ⬇️  Instalando pyvmomi $PYVMOMI_VERSION_REQUIRED..."
  if pip3 install --break-system-packages "pyvmomi==$PYVMOMI_VERSION_REQUIRED" 2>/dev/null; then
    echo "  ✅ pyvmomi instalado con --break-system-packages"
  elif pip3 install --user "pyvmomi==$PYVMOMI_VERSION_REQUIRED" 2>/dev/null; then
    echo "  ✅ pyvmomi instalado con --user"
  else
    echo "  ⚠️  Error al instalar pyvmomi, intentando método alternativo..."
    python3 -m pip install --break-system-packages "pyvmomi==$PYVMOMI_VERSION_REQUIRED" || \
      echo "  ❌ No se pudo instalar pyvmomi. Instalar manualmente: pip3 install pyvmomi==$PYVMOMI_VERSION_REQUIRED"
  fi
fi

# Verificar ansible-pylibssh (mejora rendimiento de conexiones SSH)
if check_python_package "ansible_pylibssh"; then
  echo "  ✅ ansible-pylibssh ya instalado"
else
  echo "  ⬇️  Instalando ansible-pylibssh..."
  if pip3 install --break-system-packages ansible-pylibssh 2>/dev/null; then
    echo "  ✅ ansible-pylibssh instalado con --break-system-packages"
  elif pip3 install --user ansible-pylibssh 2>/dev/null; then
    echo "  ✅ ansible-pylibssh instalado con --user"
  else
    echo "  ⚠️  No se pudo instalar ansible-pylibssh (opcional)"
  fi
fi

# Verificar otras dependencias ya instaladas vía apt
PYTHON_DEPS=("netaddr" "jinja2" "passlib" "requests" "cryptography" "jmespath")
echo ""
echo "Verificando dependencias Python (vía apt):"
for dep in "${PYTHON_DEPS[@]}"; do
  if check_python_package "$dep"; then
    echo "  ✅ $dep"
  else
    echo "  ⚠️  $dep no encontrado (debería estar instalado vía apt)"
  fi
done

# 5. Verificar e instalar Ansible Collections
echo "[5/6] Verificando Ansible Collections..."
if [[ -f requirements.yml ]]; then
  # Verificar collections instaladas
  echo "Verificando collections requeridas..."
  COLLECTIONS_TO_INSTALL=false
  
  REQUIRED_COLLECTIONS=("community.vmware" "cisco.ios" "ansible.netcommon" "ansible.posix" "ansible.utils")
  
  for collection in "${REQUIRED_COLLECTIONS[@]}"; do
    if ansible-galaxy collection list | grep -q "$collection"; then
      INSTALLED_VERSION=$(ansible-galaxy collection list | grep "$collection" | awk '{print $2}')
      echo "  ✅ $collection ($INSTALLED_VERSION)"
    else
      echo "  ⬇️  $collection (faltante)"
      COLLECTIONS_TO_INSTALL=true
    fi
  done
  
  if [ "$COLLECTIONS_TO_INSTALL" = true ]; then
    echo ""
    echo "Instalando/actualizando collections faltantes..."
    ansible-galaxy collection install -r requirements.yml --force
    echo "✅ Collections actualizadas"
  else
    echo "✅ Todas las collections ya están instaladas"
    echo "   (Usa --force para actualizar)"
  fi
else
  echo "⚠️  requirements.yml no encontrado, saltando instalación de collections"
fi

# 6. Crear estructura de evidencias
echo "[6/6] Verificando estructura de directorios..."
DIRS_CREATED=0
DIRS_EXISTED=0

REQUIRED_DIRS=(
  "evidence/configs"
  "evidence/pings"
  "evidence/pcaps"
  "evidence/services"
  "evidence/reports"
  "evidence/logs"
  "evidence/technical_reports"
  "group_vars/all"
)

for dir in "${REQUIRED_DIRS[@]}"; do
  if [ -d "$dir" ]; then
    echo "  ✅ $dir (existe)"
    ((DIRS_EXISTED++))
  else
    mkdir -p "$dir"
    echo "  ⬇️  $dir (creado)"
    ((DIRS_CREATED++))
  fi
done

if [ $DIRS_CREATED -gt 0 ]; then
  echo "✅ $DIRS_CREATED directorios creados"
fi
if [ $DIRS_EXISTED -gt 0 ]; then
  echo "✅ $DIRS_EXISTED directorios ya existían"
fi

# Permisos
chmod +x bootstrap_control_vm.sh 2>/dev/null || true

echo ""
echo "=========================================="
echo "✅ Bootstrap completado exitosamente"
echo "=========================================="
echo ""
echo "📊 Resumen:"
echo "  • Paquetes apt: ${#PACKAGES_TO_INSTALL[@]} instalados"
echo "  • pyvmomi: $(check_python_package pyVmomi && echo 'OK' || echo 'Verificar manualmente')"
echo "  • Collections: $(ansible-galaxy collection list 2>/dev/null | grep -c 'community\|cisco\|ansible' || echo '0') instaladas"
echo "  • Directorios: $DIRS_CREATED creados, $DIRS_EXISTED ya existían"
echo ""
echo "📋 Próximos pasos:"
echo "  1. Ejecutar: ansible-playbook playbooks/bootstrap_control.yml"
echo "  2. Configurar Vault: cp group_vars/all/vault.yml.template group_vars/all/vault.yml"
echo "  3. Editar credenciales: vim group_vars/all/vault.yml"
echo "  4. Cifrar Vault: ansible-vault encrypt group_vars/all/vault.yml"
echo "  5. Ejecutar: ansible-playbook playbooks/site.yml"
echo ""
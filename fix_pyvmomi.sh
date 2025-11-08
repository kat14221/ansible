#!/usr/bin/env bash
# ============================================================================
# Script de Corrección Rápida de PyVmomi
# ============================================================================
# Propósito: Desinstalar versión problemática e instalar la correcta
# Uso: ./fix_pyvmomi.sh
# ============================================================================

set -euo pipefail

echo "=============================================="
echo "🔧 Corrección de PyVmomi"
echo "=============================================="
echo ""

# Verificar versión actual
echo "[1/4] Verificando versión actual de PyVmomi..."
if python3 -c "import pyVmomi" 2>/dev/null; then
  CURRENT_VERSION=$(python3 -c "import pyVmomi; print(pyVmomi.__version__)" 2>/dev/null || echo "desconocida")
  echo "  Versión actual: $CURRENT_VERSION"
  echo "  Ubicación: $(python3 -c "import pyVmomi; print(pyVmomi.__file__)")"
else
  echo "  PyVmomi no está instalado"
  CURRENT_VERSION="none"
fi
echo ""

# Desinstalar versión actual
echo "[2/4] Desinstalando PyVmomi actual..."
if pip3 uninstall -y pyvmomi 2>/dev/null; then
  echo "  ✅ PyVmomi desinstalado"
else
  echo "  ⚠️  No se pudo desinstalar con pip3, intentando con pip..."
  pip uninstall -y pyvmomi 2>/dev/null || echo "  ℹ️  No había versión instalada con pip"
fi

# Limpiar cache de pip
echo "  Limpiando cache de pip..."
pip3 cache purge 2>/dev/null || true
echo ""

# Instalar versión correcta
echo "[3/4] Instalando PyVmomi 8.0.3.0.1..."
INSTALL_SUCCESS=false

# Intentar con --break-system-packages (Debian 12+)
if pip3 install --break-system-packages pyvmomi==8.0.3.0.1 2>/dev/null; then
  echo "  ✅ Instalado con --break-system-packages"
  INSTALL_SUCCESS=true
# Intentar con --user
elif pip3 install --user pyvmomi==8.0.3.0.1 2>/dev/null; then
  echo "  ✅ Instalado con --user"
  echo "  ⚠️  Asegúrate de tener ~/.local/bin en tu PATH"
  INSTALL_SUCCESS=true
# Intentar con python3 -m pip
elif python3 -m pip install --break-system-packages pyvmomi==8.0.3.0.1 2>/dev/null; then
  echo "  ✅ Instalado con python3 -m pip"
  INSTALL_SUCCESS=true
else
  echo "  ❌ Error al instalar PyVmomi"
  echo ""
  echo "Intenta manualmente:"
  echo "  sudo pip3 install pyvmomi==8.0.3.0.1"
  exit 1
fi
echo ""

# Verificar instalación
echo "[4/4] Verificando instalación..."
if python3 -c "import pyVmomi" 2>/dev/null; then
  NEW_VERSION=$(python3 -c "import pyVmomi; print(pyVmomi.__version__)")
  LOCATION=$(python3 -c "import pyVmomi; print(pyVmomi.__file__)")
  
  echo "  ✅ PyVmomi instalado correctamente"
  echo "  Versión: $NEW_VERSION"
  echo "  Ubicación: $LOCATION"
  
  if [[ "$NEW_VERSION" == "8.0.3.0.1" ]]; then
    echo ""
    echo "=============================================="
    echo "✅ CORRECCIÓN EXITOSA"
    echo "=============================================="
    echo ""
    echo "PyVmomi actualizado de $CURRENT_VERSION → $NEW_VERSION"
    echo ""
    echo "Ahora puedes ejecutar:"
    echo "  ansible-playbook playbooks/create_vms.yml -vvv"
    echo ""
  else
    echo ""
    echo "⚠️  ADVERTENCIA: Versión instalada ($NEW_VERSION) no es la esperada (8.0.3.0.1)"
    echo "Puede que necesites desinstalar manualmente e instalar de nuevo"
  fi
else
  echo "  ❌ Error: PyVmomi no se puede importar"
  exit 1
fi

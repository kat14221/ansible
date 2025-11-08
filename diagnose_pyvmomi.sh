#!/usr/bin/env bash
# ============================================================================
# Script de Diagnóstico de PyVmomi
# ============================================================================
# Propósito: Diagnosticar problemas con la instalación de PyVmomi
# Uso: ./diagnose_pyvmomi.sh
# ============================================================================

set -euo pipefail

echo "=============================================="
echo "🔍 Diagnóstico de PyVmomi"
echo "=============================================="
echo ""

# 1. Información del sistema
echo "[1/6] Información del Sistema"
echo "----------------------------------------"
echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo "Python: $(python3 --version)"
echo "Pip: $(pip3 --version)"
echo ""

# 2. Verificar PyVmomi
echo "[2/6] PyVmomi - Información"
echo "----------------------------------------"
if python3 -c "import pyVmomi" 2>/dev/null; then
  echo "✅ PyVmomi está instalado"
  echo ""
  echo "Versión:"
  python3 -c "import pyVmomi; print('  ', pyVmomi.__version__)"
  echo ""
  echo "Ubicación:"
  python3 -c "import pyVmomi; print('  ', pyVmomi.__file__)"
  echo ""
  echo "Módulos disponibles:"
  python3 -c "import pyVmomi; import dir; print('  ', ', '.join([x for x in dir(pyVmomi) if not x.startswith('_')][:10]))" 2>/dev/null || echo "  (no se pudo listar)"
else
  echo "❌ PyVmomi NO está instalado"
fi
echo ""

# 3. Verificar instalaciones de pip
echo "[3/6] Instalaciones de PyVmomi (pip)"
echo "----------------------------------------"
echo "Sistema (pip3 list):"
pip3 list 2>/dev/null | grep -i vmomi || echo "  No encontrado"
echo ""
echo "Usuario (pip3 list --user):"
pip3 list --user 2>/dev/null | grep -i vmomi || echo "  No encontrado"
echo ""

# 4. Verificar múltiples instalaciones
echo "[4/6] Búsqueda de Múltiples Instalaciones"
echo "----------------------------------------"
echo "Buscando archivos pyVmomi en el sistema..."
find /usr -name "*pyVmomi*" 2>/dev/null | head -10 || echo "  No encontrado en /usr"
find ~/.local -name "*pyVmomi*" 2>/dev/null | head -10 || echo "  No encontrado en ~/.local"
echo ""

# 5. Test de importación detallado
echo "[5/6] Test de Importación Detallado"
echo "----------------------------------------"
python3 << 'EOF'
import sys
print("Python executable:", sys.executable)
print("Python path:")
for p in sys.path:
    print("  ", p)
print()

try:
    import pyVmomi
    print("✅ pyVmomi importado exitosamente")
    print("   Versión:", pyVmomi.__version__)
    print("   Archivo:", pyVmomi.__file__)
    
    # Verificar VmomiJSONEncoder
    try:
        from pyVmomi import VmomiSupport
        if hasattr(VmomiSupport, 'VmomiJSONEncoder'):
            print("   ✅ VmomiJSONEncoder disponible")
        else:
            print("   ❌ VmomiJSONEncoder NO disponible (versión antigua)")
    except Exception as e:
        print("   ⚠️  Error al verificar VmomiJSONEncoder:", e)
        
except ImportError as e:
    print("❌ Error al importar pyVmomi:", e)
except Exception as e:
    print("❌ Error inesperado:", e)
EOF
echo ""

# 6. Verificar community.vmware
echo "[6/6] Ansible Collection community.vmware"
echo "----------------------------------------"
if command -v ansible-galaxy &> /dev/null; then
  echo "Versión instalada:"
  ansible-galaxy collection list 2>/dev/null | grep community.vmware || echo "  No encontrada"
  echo ""
  echo "Ubicación:"
  ansible-galaxy collection list -p 2>/dev/null | grep -A1 community.vmware || echo "  No encontrada"
else
  echo "❌ ansible-galaxy no está disponible"
fi
echo ""

# Resumen y recomendaciones
echo "=============================================="
echo "📋 Resumen y Recomendaciones"
echo "=============================================="
echo ""

# Verificar versión de PyVmomi
PYVMOMI_VERSION=$(python3 -c "import pyVmomi; print(pyVmomi.__version__)" 2>/dev/null || echo "none")

if [[ "$PYVMOMI_VERSION" == "none" ]]; then
  echo "❌ PROBLEMA: PyVmomi no está instalado"
  echo ""
  echo "SOLUCIÓN:"
  echo "  ./fix_pyvmomi.sh"
  echo "  O manualmente:"
  echo "  pip3 install --break-system-packages pyvmomi==8.0.3.0.1"
  
elif [[ "$PYVMOMI_VERSION" != "8.0.3.0.1" ]]; then
  echo "⚠️  PROBLEMA: Versión incorrecta de PyVmomi ($PYVMOMI_VERSION)"
  echo ""
  echo "SOLUCIÓN:"
  echo "  ./fix_pyvmomi.sh"
  echo "  O manualmente:"
  echo "  pip3 uninstall -y pyvmomi"
  echo "  pip3 install --break-system-packages pyvmomi==8.0.3.0.1"
  
else
  echo "✅ PyVmomi está correctamente instalado (versión $PYVMOMI_VERSION)"
  echo ""
  echo "Si aún tienes errores, verifica:"
  echo "  1. Actualizar community.vmware:"
  echo "     ansible-galaxy collection install community.vmware --force"
  echo "  2. Reiniciar sesión de terminal"
  echo "  3. Verificar que no hay múltiples instalaciones de PyVmomi"
fi
echo ""

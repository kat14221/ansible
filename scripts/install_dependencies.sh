#!/bin/bash
# Script para instalar dependencias faltantes de Ansible

set -euo pipefail

echo "🔧 Instalando dependencias faltantes de Ansible..."

# Instalar paquetes del sistema
echo "📦 Instalando paquetes del sistema..."
sudo apt update
sudo apt install -y python3-paramiko python3-bcrypt python3-nacl

# Instalar paquetes Python opcionales
echo "🐍 Instalando paquetes Python opcionales..."
pip3 install --break-system-packages ansible-pylibssh 2>/dev/null || echo "⚠️ ansible-pylibssh no se pudo instalar (opcional)"
pip3 install --break-system-packages pyvmomi 2>/dev/null || echo "⚠️ pyvmomi ya debe estar instalado"

# Verificar instalaciones
echo "✅ Verificando instalaciones..."
python3 -c "import paramiko; print('✅ Paramiko OK')"
python3 -c "import pyVmomi; print('✅ pyvmomi OK')" 2>/dev/null || echo "⚠️ pyvmomi no disponible"
python3 -c "try: import ansible_pylibssh; print('✅ ansible-pylibssh OK'); except: print('⚠️ ansible-pylibssh no disponible (opcional)')"

echo "🎉 Dependencias instaladas correctamente"
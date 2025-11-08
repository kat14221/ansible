# 📚 Buenas Prácticas - Gestión de Dependencias Ansible

## 🎯 Resumen Ejecutivo

Este documento establece las mejores prácticas para gestionar dependencias en proyectos Ansible, específicamente para infraestructura VMware y Cisco.

---

## 📦 Versiones Recomendadas

### Python y Sistema Base

```bash
# Sistema operativo
Ubuntu 24.04 LTS o Debian 12 (Bookworm)

# Python
python3 >= 3.11 (incluido en Ubuntu 24.04/Debian 12)
python3-pip (gestor de paquetes)
python3-venv (entornos virtuales)
```

### Ansible

```bash
# Ansible Core
ansible >= 2.16.0

# Instalación recomendada (vía apt en Debian/Ubuntu)
sudo apt install ansible
```

### PyVmomi (VMware SDK)

```bash
# Versión ESPECÍFICA recomendada
pyvmomi == 8.0.3.0.1

# ¿Por qué esta versión?
# ✅ Compatible con ESXi 8.0 U2
# ✅ Sin deprecation warnings de VmomiJSONEncoder
# ✅ Estable y probada
# ❌ Evitar: pyvmomi >= 8.0.0.1 (puede traer versiones con bugs)
```

### Ansible Collections

```yaml
# requirements.yml
collections:
  - name: community.vmware
    version: ">=4.0.0"  # Última estable compatible con pyvmomi 8.0.3
  
  - name: cisco.ios
    version: ">=6.0.0"
  
  - name: ansible.netcommon
    version: ">=6.0.0"
  
  - name: ansible.posix
    version: ">=1.5.0"
  
  - name: ansible.utils
    version: ">=3.0.0"
```

---

## 🏗️ Estrategias de Instalación

### 1. Instalación en Sistema (Recomendado para VMs dedicadas)

```bash
# Ventajas:
# ✅ Simple y directo
# ✅ Disponible para todos los usuarios
# ✅ Integración con systemd

# Desventajas:
# ⚠️ Puede conflictuar con paquetes del sistema
# ⚠️ Requiere --break-system-packages en Debian 12+

# Comando:
pip3 install --break-system-packages pyvmomi==8.0.3.0.1
```

### 2. Instalación por Usuario (Alternativa segura)

```bash
# Ventajas:
# ✅ No requiere sudo
# ✅ No afecta sistema global
# ✅ Aislado por usuario

# Desventajas:
# ⚠️ Solo disponible para el usuario actual
# ⚠️ Requiere agregar ~/.local/bin al PATH

# Comando:
pip3 install --user pyvmomi==8.0.3.0.1

# Agregar al PATH (en ~/.bashrc):
export PATH="$HOME/.local/bin:$PATH"
```

### 3. Entorno Virtual (Mejor para desarrollo)

```bash
# Ventajas:
# ✅ Aislamiento total
# ✅ Múltiples versiones en paralelo
# ✅ Reproducible

# Desventajas:
# ⚠️ Requiere activar el entorno
# ⚠️ Más complejo de gestionar

# Comandos:
python3 -m venv ~/ansible-venv
source ~/ansible-venv/bin/activate
pip install pyvmomi==8.0.3.0.1 ansible
```

---

## 🔧 Instalación Idempotente

### Script Bash (bootstrap_control_vm.sh)

```bash
# Principios:
# 1. Verificar antes de instalar
# 2. Usar versiones específicas
# 3. Manejar errores gracefully
# 4. Proporcionar feedback claro

# Ejemplo de verificación:
check_python_package() {
  python3 -c "import $1" 2>/dev/null
}

if check_python_package "pyVmomi"; then
  VERSION=$(python3 -c "import pyVmomi; print(pyVmomi.__version__)")
  echo "✅ pyvmomi ya instalado (versión: $VERSION)"
  
  # Verificar si necesita actualización
  if [[ "$VERSION" < "8.0.3" ]]; then
    echo "⚠️ Actualizando a versión recomendada..."
    pip3 install --upgrade pyvmomi==8.0.3.0.1
  fi
else
  echo "⬇️ Instalando pyvmomi..."
  pip3 install pyvmomi==8.0.3.0.1
fi
```

---

## 📋 Dependencias por Categoría

### Dependencias del Sistema (apt)

```bash
# Esenciales
python3              # Intérprete Python
python3-pip          # Gestor de paquetes
python3-venv         # Entornos virtuales
ansible              # Ansible core

# Desarrollo
build-essential      # Compiladores (gcc, make)
libssl-dev          # Headers SSL
libffi-dev          # Headers FFI

# Networking
sshpass             # Autenticación SSH con password
net-tools           # ifconfig, netstat
iputils-ping        # ping

# Utilidades
git                 # Control de versiones
jq                  # Procesador JSON
vim                 # Editor de texto
curl, wget          # Descarga de archivos
```

### Dependencias Python (pip)

```bash
# VMware
pyvmomi==8.0.3.0.1          # SDK VMware (VERSIÓN ESPECÍFICA)

# Ansible (opcional, mejora rendimiento)
ansible-pylibssh            # SSH más rápido que paramiko

# Networking
netaddr                     # Manipulación de IPs (preferir apt)
jmespath                    # Queries JSON (preferir apt)

# Seguridad
passlib                     # Hashing de passwords (preferir apt)
cryptography                # Criptografía (preferir apt)
bcrypt                      # Hashing bcrypt (preferir apt)
```

### Preferencia: apt > pip

```bash
# ✅ CORRECTO: Instalar desde apt cuando esté disponible
sudo apt install python3-netaddr python3-jinja2 python3-passlib

# ❌ EVITAR: Instalar desde pip si existe en apt
pip3 install netaddr jinja2 passlib
```

**Razón:** Los paquetes apt están:
- Probados con el sistema operativo
- Gestionados por el sistema de actualizaciones
- Sin conflictos de dependencias

---

## 🐛 Solución de Problemas Comunes

### Error: "No longer supported. Use pyVmomi.VmomiJSONEncoder"

```bash
# Causa: Versión antigua de pyvmomi
# Solución:
pip3 install --upgrade pyvmomi==8.0.3.0.1

# Verificar versión instalada:
python3 -c "import pyVmomi; print(pyVmomi.__version__)"
```

### Error: "Unsupported parameters for (community.vmware.vmware_guest) module"

```bash
# Causa: Parámetros no soportados por el módulo
# Solución: Verificar documentación oficial

# Parámetros NO soportados en vmware_guest:
# - hardware.usb_controller (debe configurarse post-creación)
# - hardware.video (limitado)

# Consultar documentación:
ansible-doc community.vmware.vmware_guest
```

### Error: "externally-managed-environment"

```bash
# Causa: Debian 12+ protege el Python del sistema
# Solución 1 (recomendada para VMs dedicadas):
pip3 install --break-system-packages pyvmomi==8.0.3.0.1

# Solución 2 (más segura):
pip3 install --user pyvmomi==8.0.3.0.1

# Solución 3 (desarrollo):
python3 -m venv ~/venv && source ~/venv/bin/activate
pip install pyvmomi==8.0.3.0.1
```

### Error: Collection version incompatible

```bash
# Causa: Versión de collection incompatible con Ansible
# Solución: Actualizar Ansible o ajustar versión de collection

# Ver versión de Ansible:
ansible --version

# Ver collections instaladas:
ansible-galaxy collection list

# Actualizar collection específica:
ansible-galaxy collection install community.vmware --force
```

---

## 📊 Matriz de Compatibilidad

| Componente | Versión Mínima | Versión Recomendada | Notas |
|------------|----------------|---------------------|-------|
| **Ubuntu** | 22.04 LTS | 24.04 LTS | Soporte hasta 2029 |
| **Debian** | 11 (Bullseye) | 12 (Bookworm) | Soporte hasta 2028 |
| **Python** | 3.9 | 3.11+ | Incluido en Ubuntu 24.04 |
| **Ansible** | 2.14 | 2.16+ | Core, no ansible-base |
| **PyVmomi** | 8.0.0 | **8.0.3.0.1** | ⚠️ Usar versión exacta |
| **ESXi** | 7.0 | 8.0 U2 | Compatibilidad con pyvmomi |
| **community.vmware** | 3.0.0 | 4.0.0+ | Requiere pyvmomi 8.0+ |
| **cisco.ios** | 5.0.0 | 6.0.0+ | Compatible con netcommon 6.0 |

---

## 🔒 Seguridad y Actualizaciones

### Política de Actualizaciones

```bash
# ✅ HACER: Actualizar regularmente
sudo apt update && sudo apt upgrade -y

# ✅ HACER: Actualizar collections
ansible-galaxy collection install -r requirements.yml --force

# ⚠️ CUIDADO: Actualizar pyvmomi solo a versiones probadas
pip3 install --upgrade pyvmomi==8.0.3.0.1  # Versión específica

# ❌ EVITAR: Actualizar a última versión sin probar
pip3 install --upgrade pyvmomi  # Puede romper compatibilidad
```

### Verificación de Integridad

```bash
# Verificar checksums de paquetes
pip3 install --require-hashes pyvmomi==8.0.3.0.1

# Verificar firmas de collections
ansible-galaxy collection verify community.vmware

# Auditar dependencias
pip3 list --outdated
```

---

## 📝 Checklist de Instalación

### Pre-instalación

- [ ] Sistema operativo actualizado (`sudo apt update && sudo apt upgrade`)
- [ ] Python 3.11+ instalado (`python3 --version`)
- [ ] pip instalado (`pip3 --version`)
- [ ] Ansible instalado (`ansible --version`)

### Instalación de Dependencias

- [ ] Paquetes del sistema instalados (ver lista apt)
- [ ] PyVmomi 8.0.3.0.1 instalado (`python3 -c "import pyVmomi; print(pyVmomi.__version__)"`)
- [ ] Collections instaladas (`ansible-galaxy collection list`)
- [ ] Dependencias Python verificadas (`pip3 list`)

### Post-instalación

- [ ] Estructura de directorios creada (`evidence/`, `group_vars/`)
- [ ] ansible.cfg configurado
- [ ] Claves SSH generadas
- [ ] Vault configurado (si aplica)

### Verificación

```bash
# Test completo de dependencias
./bootstrap_control_vm.sh

# Verificar Ansible
ansible --version
ansible-galaxy collection list

# Verificar Python
python3 -c "import pyVmomi, netaddr, jinja2, passlib; print('✅ Todas las dependencias OK')"

# Test de conectividad VMware
ansible-playbook playbooks/test_vmware_connection.yml
```

---

## 🎓 Recursos Adicionales

### Documentación Oficial

- **Ansible**: https://docs.ansible.com/
- **PyVmomi**: https://github.com/vmware/pyvmomi
- **community.vmware**: https://docs.ansible.com/ansible/latest/collections/community/vmware/
- **cisco.ios**: https://docs.ansible.com/ansible/latest/collections/cisco/ios/

### Troubleshooting

- **Ansible Galaxy Issues**: https://github.com/ansible-collections/community.vmware/issues
- **PyVmomi Issues**: https://github.com/vmware/pyvmomi/issues
- **Stack Overflow**: Tag `ansible` + `vmware`

### Comunidad

- **Ansible Forum**: https://forum.ansible.com/
- **Reddit**: r/ansible
- **Discord**: Ansible Community

---

## 🔄 Mantenimiento Continuo

### Mensual

- Revisar actualizaciones de seguridad del sistema
- Verificar logs de Ansible (`evidence/logs/ansible.log`)
- Actualizar collections si hay nuevas versiones estables

### Trimestral

- Revisar versiones de dependencias Python
- Evaluar actualización de PyVmomi (solo si hay bugfixes críticos)
- Auditar playbooks para deprecations

### Anual

- Considerar actualización de sistema operativo (LTS)
- Revisar arquitectura de dependencias
- Actualizar documentación

---

## ✅ Resumen de Mejores Prácticas

1. **Usar versiones específicas** para dependencias críticas (pyvmomi)
2. **Preferir apt sobre pip** cuando el paquete esté disponible
3. **Verificar antes de instalar** (idempotencia)
4. **Documentar versiones** en requirements.yml y scripts
5. **Probar actualizaciones** en entorno de desarrollo primero
6. **Mantener logs** de instalaciones y cambios
7. **Automatizar verificaciones** con scripts de bootstrap
8. **Usar entornos virtuales** para desarrollo
9. **Actualizar regularmente** pero con versiones probadas
10. **Documentar problemas** y soluciones para el equipo

---

**Última actualización:** 2025-01-XX  
**Versión del documento:** 1.0  
**Mantenedor:** Equipo de Infraestructura

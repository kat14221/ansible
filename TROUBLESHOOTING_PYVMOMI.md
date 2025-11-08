# 🔧 Troubleshooting: Error PyVmomi VmomiJSONEncoder

## 🚨 Error Completo

```
Exception: No longer supported. Use pyVmomi.VmomiJSONEncoder instead.
```

Este error aparece al ejecutar playbooks que usan `community.vmware.vmware_guest`.

---

## 🎯 Causa Raíz

El error ocurre porque:

1. **Versión incorrecta de PyVmomi**: Tienes instalada una versión de PyVmomi que tiene un bug en el encoder JSON
2. **Incompatibilidad con community.vmware**: La collection `community.vmware` usa el encoder antiguo que fue deprecado
3. **Múltiples instalaciones**: Puede haber múltiples versiones de PyVmomi instaladas en diferentes ubicaciones

---

## ✅ Solución Rápida (Recomendada)

### Opción 1: Script Automático

```bash
# Ejecutar script de corrección
./fix_pyvmomi.sh

# Verificar corrección
./diagnose_pyvmomi.sh
```

### Opción 2: Manual

```bash
# 1. Desinstalar versión actual
pip3 uninstall -y pyvmomi

# 2. Limpiar cache
pip3 cache purge

# 3. Instalar versión correcta
pip3 install --break-system-packages pyvmomi==8.0.3.0.1

# 4. Verificar instalación
python3 -c "import pyVmomi; print(pyVmomi.__version__)"
# Debe mostrar: 8.0.3.0.1
```

---

## 🔍 Diagnóstico Paso a Paso

### 1. Verificar Versión Actual

```bash
python3 -c "import pyVmomi; print(pyVmomi.__version__)"
```

**Resultado esperado**: `8.0.3.0.1`

**Si muestra otra versión o error**: Continuar con los siguientes pasos

### 2. Verificar Ubicación de Instalación

```bash
python3 -c "import pyVmomi; print(pyVmomi.__file__)"
```

**Ubicaciones posibles**:
- `/usr/local/lib/python3.12/dist-packages/pyVmomi/` (instalación con --break-system-packages)
- `/usr/lib/python3/dist-packages/pyVmomi/` (instalación del sistema)
- `~/.local/lib/python3.12/site-packages/pyVmomi/` (instalación con --user)

### 3. Buscar Múltiples Instalaciones

```bash
# Buscar en sistema
find /usr -name "*pyVmomi*" 2>/dev/null

# Buscar en usuario
find ~/.local -name "*pyVmomi*" 2>/dev/null

# Listar con pip
pip3 list | grep -i vmomi
pip3 list --user | grep -i vmomi
```

**Si encuentras múltiples instalaciones**: Desinstalar todas y reinstalar solo una

### 4. Verificar Encoder JSON

```bash
python3 << 'EOF'
from pyVmomi import VmomiSupport
if hasattr(VmomiSupport, 'VmomiJSONEncoder'):
    print("✅ VmomiJSONEncoder disponible")
else:
    print("❌ VmomiJSONEncoder NO disponible (versión antigua)")
EOF
```

---

## 🛠️ Soluciones Avanzadas

### Problema: Múltiples Instalaciones

Si tienes PyVmomi instalado en múltiples ubicaciones:

```bash
# Desinstalar TODAS las versiones
pip3 uninstall -y pyvmomi
pip uninstall -y pyvmomi
sudo pip3 uninstall -y pyvmomi

# Eliminar manualmente si persiste
sudo rm -rf /usr/local/lib/python3.*/dist-packages/pyVmomi*
sudo rm -rf /usr/lib/python3/dist-packages/pyVmomi*
rm -rf ~/.local/lib/python3.*/site-packages/pyVmomi*

# Reinstalar versión correcta
pip3 install --break-system-packages pyvmomi==8.0.3.0.1
```

### Problema: Permisos Insuficientes

```bash
# Si no tienes permisos sudo, instalar en usuario
pip3 install --user pyvmomi==8.0.3.0.1

# Agregar al PATH (en ~/.bashrc)
export PATH="$HOME/.local/bin:$PATH"

# Recargar configuración
source ~/.bashrc
```

### Problema: Error "externally-managed-environment"

En Debian 12+ y Ubuntu 24.04+:

```bash
# Opción 1: Usar --break-system-packages (recomendado para VMs dedicadas)
pip3 install --break-system-packages pyvmomi==8.0.3.0.1

# Opción 2: Usar entorno virtual (recomendado para desarrollo)
python3 -m venv ~/ansible-venv
source ~/ansible-venv/bin/activate
pip install pyvmomi==8.0.3.0.1 ansible

# Opción 3: Instalar en usuario
pip3 install --user pyvmomi==8.0.3.0.1
```

### Problema: Collection community.vmware Desactualizada

```bash
# Actualizar collection
ansible-galaxy collection install community.vmware --force

# Verificar versión
ansible-galaxy collection list | grep community.vmware
# Debe ser >= 4.0.0
```

---

## 📊 Matriz de Compatibilidad

| PyVmomi | community.vmware | ESXi | Estado |
|---------|------------------|------|--------|
| 8.0.3.0.1 | >= 4.0.0 | 8.0 U2 | ✅ Recomendado |
| 8.0.2.x | >= 3.0.0 | 8.0 | ⚠️ Puede tener bugs |
| 8.0.1.x | >= 3.0.0 | 8.0 | ❌ Bug VmomiJSONEncoder |
| 8.0.0.x | >= 3.0.0 | 8.0 | ❌ Bug VmomiJSONEncoder |
| 7.x.x | >= 2.0.0 | 7.0 | ❌ Incompatible con ESXi 8.0 |

---

## 🧪 Tests de Verificación

### Test 1: Importación Básica

```bash
python3 -c "import pyVmomi; print('✅ OK')"
```

### Test 2: Versión Correcta

```bash
python3 -c "import pyVmomi; assert pyVmomi.__version__ == '8.0.3.0.1', 'Versión incorrecta'; print('✅ Versión correcta')"
```

### Test 3: VmomiJSONEncoder Disponible

```bash
python3 -c "from pyVmomi.VmomiSupport import VmomiJSONEncoder; print('✅ VmomiJSONEncoder disponible')"
```

### Test 4: Conexión a ESXi (requiere credenciales)

```bash
python3 << 'EOF'
from pyVim.connect import SmartConnect
import ssl

context = ssl._create_unverified_context()
try:
    si = SmartConnect(
        host="172.17.25.1",
        user="root",
        pwd="qwe123$",
        sslContext=context
    )
    print("✅ Conexión exitosa a ESXi")
except Exception as e:
    print(f"❌ Error de conexión: {e}")
EOF
```

### Test 5: Playbook Mínimo

```bash
# Crear test playbook
cat > /tmp/test_vmware.yml << 'EOF'
---
- hosts: localhost
  gather_facts: no
  tasks:
    - name: Test VMware connection
      community.vmware.vmware_vm_info:
        hostname: "172.17.25.1"
        username: "root"
        password: "qwe123$"
        validate_certs: no
      register: result
      
    - debug:
        msg: "✅ Conexión exitosa. VMs encontradas: {{ result.virtual_machines | length }}"
EOF

# Ejecutar test
ansible-playbook /tmp/test_vmware.yml
```

---

## 📝 Checklist de Verificación

Después de aplicar la solución, verifica:

- [ ] PyVmomi versión 8.0.3.0.1 instalado
- [ ] Solo UNA instalación de PyVmomi en el sistema
- [ ] VmomiJSONEncoder disponible
- [ ] community.vmware >= 4.0.0 instalado
- [ ] Test de importación exitoso
- [ ] Test de conexión a ESXi exitoso
- [ ] Playbook create_vms.yml ejecuta sin errores

---

## 🆘 Si Nada Funciona

### Opción Nuclear: Reinstalación Completa

```bash
# 1. Desinstalar todo
pip3 uninstall -y pyvmomi ansible
ansible-galaxy collection list | grep community.vmware | awk '{print $1}' | xargs -I {} ansible-galaxy collection remove {}

# 2. Limpiar cache
pip3 cache purge
rm -rf ~/.ansible/collections/ansible_collections/community/vmware

# 3. Reinstalar desde cero
pip3 install --break-system-packages pyvmomi==8.0.3.0.1
pip3 install --break-system-packages ansible
ansible-galaxy collection install community.vmware

# 4. Verificar
./verify_dependencies.sh
```

### Opción Entorno Virtual Limpio

```bash
# 1. Crear entorno virtual nuevo
python3 -m venv ~/ansible-clean-venv

# 2. Activar
source ~/ansible-clean-venv/bin/activate

# 3. Instalar dependencias
pip install pyvmomi==8.0.3.0.1 ansible

# 4. Instalar collections
ansible-galaxy collection install -r requirements.yml

# 5. Ejecutar playbooks desde este entorno
ansible-playbook playbooks/create_vms.yml -vvv
```

---

## 📞 Soporte Adicional

Si después de seguir todos estos pasos el error persiste:

1. **Ejecutar diagnóstico completo**:
   ```bash
   ./diagnose_pyvmomi.sh > diagnostico.txt
   ```

2. **Revisar logs de Ansible**:
   ```bash
   cat evidence/logs/ansible.log
   ```

3. **Verificar versiones**:
   ```bash
   python3 --version
   ansible --version
   pip3 --version
   cat /etc/os-release
   ```

4. **Consultar documentación oficial**:
   - PyVmomi: https://github.com/vmware/pyvmomi/issues
   - community.vmware: https://github.com/ansible-collections/community.vmware/issues

---

## 📚 Referencias

- **PyVmomi Release Notes**: https://github.com/vmware/pyvmomi/releases
- **community.vmware Changelog**: https://github.com/ansible-collections/community.vmware/blob/main/CHANGELOG.rst
- **Ansible VMware Guide**: https://docs.ansible.com/ansible/latest/scenario_guides/guide_vmware.html
- **Buenas Prácticas**: Ver `BUENAS_PRACTICAS_DEPENDENCIAS.md`

---

**Última actualización**: 2025-01-XX  
**Versión**: 1.0

# 🚀 Bootstrap y Uso del Proyecto

## Descripción General

Este documento describe cómo restaurar completamente la VM de control de Ansible desde cero y ejecutar el proyecto sin configuración manual.

## 📋 Requisitos Previos

- VM con Ubuntu/Debian 12+ recién instalada
- Acceso root o sudo
- Conexión a internet
- Clonar este repositorio

## 1️⃣ Restaurar VM de Control desde Cero

### Paso 1: Ejecutar Bootstrap Script

```bash
cd /ruta/al/proyecto/ansible
chmod +x bootstrap_control_vm.sh
./bootstrap_control_vm.sh
```

**Este script instala:**
- Python 3 y pip
- Ansible
- Dependencias del sistema (git, sshpass, build-essential, etc.)
- Dependencias Python desde `requirements-pip.txt`
- Collections de Ansible desde `requirements.yml`
- Estructura de directorios `evidence/`

### Paso 2: Ejecutar Playbook de Post-Instalación

```bash
ansible-playbook playbooks/bootstrap_control.yml
```

**Este playbook configura:**
- Directorios de evidencias
- Archivo `ansible.cfg` (si no existe)
- Par de llaves SSH (`~/.ssh/id_rsa_ansible`)
- Valida instalación de collections y dependencias

---

## 2️⃣ Configurar Vault (Credenciales)

### Crear Vault desde Template

```bash
# Copiar template
cp group_vars/all/vault.yml.template group_vars/all/vault.yml

# Editar con credenciales reales
vim group_vars/all/vault.yml

# Cifrar con Ansible Vault
ansible-vault encrypt group_vars/all/vault.yml
```

### Configurar Password de Vault

**Opción A: Archivo de contraseña (recomendado)**
```bash
echo "tu_contraseña_vault_segura" > .vault_pass
chmod 600 .vault_pass
```

**Opción B: Usar --ask-vault-pass en cada ejecución**
```bash
ansible-playbook playbooks/site.yml --ask-vault-pass
```

### Editar Vault Existente

```bash
ansible-vault edit group_vars/all/vault.yml
```

---

## 3️⃣ Ejecutar Proyecto Completo

### Ejecución Normal (con .vault_pass configurado)

```bash
ansible-playbook playbooks/site.yml
```

### Ejecución con Password Interactivo

```bash
ansible-playbook playbooks/site.yml --ask-vault-pass
```

### Ejecución por Tags (solo ciertas secciones)

```bash
# Solo configurar IOS
ansible-playbook playbooks/site.yml --tags ios

# Solo crear VMs
ansible-playbook playbooks/site.yml --tags vm_creation

# Solo firewall y seguridad
ansible-playbook playbooks/site.yml --tags firewall,security

# Solo recolectar evidencias
ansible-playbook playbooks/site.yml --tags evidence
```

---

## 4️⃣ Validar Conectividad y Evidencias

### Ejecutar Validación Completa

```bash
ansible-playbook playbooks/validate_connectivity.yml
```

### Verificar Evidencias Generadas

```bash
ls -la evidence/
ls -la evidence/configs/
ls -la evidence/pings/
ls -la evidence/pcaps/
ls -la evidence/reports/
```

---

## 📂 Estructura de Evidencias

```
evidence/
├── configs/          # Configuraciones de red (ip -6 addr, ip -6 route, running-config)
├── pings/            # Resultados de pruebas de conectividad (ping6)
├── pcaps/            # Capturas de tráfico IPv6
├── services/         # Estado de servicios (HTTP, FTP, etc.)
├── reports/          # Reportes JSON consolidados por host
└── logs/             # Logs de ejecución de Ansible
```

---

## 🔐 Gestión de Credenciales

### Variables en Vault

El archivo `group_vars/all/vault.yml` contiene:

- `vault_vcenter_hostname` - Host de ESXi/vCenter
- `vault_vcenter_username` - Usuario de vCenter
- `vault_vcenter_password` - Contraseña de vCenter
- `vault_ansible_ssh_public_key` - Clave SSH pública
- `vault_cisco_user` / `vault_cisco_password` - Credenciales Cisco IOS
- `vault_ftp_user` / `vault_ftp_password` - Credenciales FTP

### Copiar Clave SSH a Hosts Remotos

```bash
# Ver clave pública generada
cat ~/.ssh/id_rsa_ansible.pub

# Copiar a host remoto
ssh-copy-id -i ~/.ssh/id_rsa_ansible.pub ansible@<host_ip>
```

---

## ⚙️ Dependencias

### Collections de Ansible (`requirements.yml`)

- `community.vmware` - Gestión de VMs en ESXi
- `cisco.ios` - Configuración de equipos Cisco IOS
- `ansible.netcommon` - Módulos de red comunes
- `ansible.posix` - Firewalld y herramientas POSIX
- `ansible.utils` - Utilidades adicionales

### Paquetes Python (`requirements-pip.txt`)

- `pyvmomi` - SDK de VMware para Python
- `netaddr` - Manipulación de direcciones IP
- `jinja2` - Motor de templates
- `passlib` - Hash de contraseñas
- `requests` - Cliente HTTP

---

## 🔄 Workflow Completo

```bash
# 1. Bootstrap inicial (solo primera vez)
./bootstrap_control_vm.sh
ansible-playbook playbooks/bootstrap_control.yml

# 2. Configurar Vault (solo primera vez)
cp group_vars/all/vault.yml.template group_vars/all/vault.yml
ansible-vault encrypt group_vars/all/vault.yml
echo "mi_password" > .vault_pass
chmod 600 .vault_pass

# 3. Ejecutar proyecto completo
ansible-playbook playbooks/site.yml

# 4. Validar evidencias
ansible-playbook playbooks/validate_connectivity.yml
ls -la evidence/
```

---

## 🆘 Solución de Problemas

### Error: "vault password file not found"

```bash
# Crear archivo .vault_pass
echo "tu_contraseña" > .vault_pass
chmod 600 .vault_pass
```

### Error: "Collection not found"

```bash
# Reinstalar collections
ansible-galaxy collection install -r requirements.yml --force
```

### Error: "No module named 'pyvmomi'"

```bash
# Reinstalar dependencias Python
pip3 install --user -r requirements-pip.txt
```

### VMs ya existen (error de duplicación)

Los roles ahora son idempotentes y reutilizan VMs existentes. No es necesario eliminarlas manualmente.

---

## 📊 Verificación de Estado

### Ver Collections Instaladas

```bash
ansible-galaxy collection list
```

### Ver Dependencias Python

```bash
pip3 list | grep -E 'pyvmomi|netaddr|passlib'
```

### Ver Configuración de Ansible

```bash
ansible-config dump
```

---

## 🎯 Criterios de Aceptación

### ✅ Bootstrap Exitoso

- Ejecutar `./bootstrap_control_vm.sh` sin errores
- Ejecutar `ansible-playbook playbooks/bootstrap_control.yml` sin errores
- Ejecutar `ansible-playbook playbooks/site.yml` sin configuración manual adicional

### ✅ Evidencias Generadas

Después de ejecutar `site.yml`, deben existir:
- `evidence/configs/` con al menos 1 archivo
- `evidence/pings/` con al menos 1 archivo
- `evidence/reports/` con reportes JSON por host
- `evidence/pcaps/` con capturas de tráfico

### ✅ Conectividad IPv6

- Ping desde `2025:db8:100::/64` → `2025:db8:101::/64` ✅
- Ping desde `2025:db8:101::/64` → `2025:db8:100::/64` ❌ (bloqueado por firewall)

---

## 📚 Referencias

- [Documentación de Ansible Vault](https://docs.ansible.com/ansible/latest/vault_guide/index.html)
- [Community VMware Collection](https://docs.ansible.com/ansible/latest/collections/community/vmware/index.html)
- [Cisco IOS Collection](https://docs.ansible.com/ansible/latest/collections/cisco/ios/index.html)
- [Firewalld Module](https://docs.ansible.com/ansible/latest/collections/ansible/posix/firewalld_module.html)

# 🎯 Implementación Completa - 12 Puntos

## ✅ Estado de Implementación

### **Punto 1: Bootstrap de VM de Control** ✅
**Archivos:**
- `bootstrap_control_vm.sh` - Script de instalación automática
- `playbooks/bootstrap_control.yml` - Playbook de post-instalación
- `requirements.yml` - Collections de Ansible
- `requirements-pip.txt` - Dependencias Python

**Uso:**
```bash
./bootstrap_control_vm.sh
ansible-playbook playbooks/bootstrap_control.yml
```

---

### **Punto 2: VMs Idempotentes** ✅
**Archivos modificados:**
- `roles/vmware-router/tasks/main.yml`
- `roles/vmware-ubuntu/tasks/main.yml`
- `roles/vmware-windows/tasks/main.yml`

**Cambios:**
- Verifica existencia con `vmware_guest_info` antes de crear
- Reutiliza VMs existentes
- Evita duplicaciones

---

### **Punto 3: Ansible Vault** ✅
**Archivos:**
- `group_vars/all/vault.yml.template` - Template con credenciales
- `.gitignore` - Actualizado para excluir vault

**Configuración:**
```bash
cp group_vars/all/vault.yml.template group_vars/all/vault.yml
vim group_vars/all/vault.yml  # Editar credenciales reales
ansible-vault encrypt group_vars/all/vault.yml
echo "password" > .vault_pass
chmod 600 .vault_pass
```

**Variables protegidas:**
- `vault_vcenter_hostname`
- `vault_vcenter_username`
- `vault_vcenter_password`
- `vault_cisco_user`
- `vault_cisco_password`
- `vault_ansible_ssh_public_key`
- `vault_ftp_user` / `vault_ftp_password`

---

### **Punto 4: Dependencias Centralizadas** ✅
**Archivos:**
- `requirements.yml` - Collections:
  - `community.vmware`
  - `cisco.ios`
  - `ansible.netcommon`
  - `ansible.posix`
  - `ansible.utils`

- `requirements-pip.txt` - Python:
  - `pyvmomi`
  - `netaddr`
  - `jinja2`
  - `passlib`
  - `requests`

**Instalación:**
```bash
ansible-galaxy collection install -r requirements.yml --force
pip3 install --user -r requirements-pip.txt
```

---

### **Punto 5: Evidencias Automáticas** ✅
**Archivos:**
- `roles/evidence-collector/tasks/main.yml`
- `playbooks/validate_connectivity.yml`

**Estructura:**
```
evidence/
├── configs/     # ip -6 addr, ip -6 route, running-config
├── pings/       # Resultados de ping6
├── pcaps/       # Capturas de tráfico
├── services/    # Estado de servicios
├── reports/     # Reportes JSON
└── logs/        # Logs de Ansible
```

**Recolección automática:**
- Direccionamiento IPv6 (Linux)
- Rutas IPv6
- Running-config (Cisco IOS)
- Pruebas de conectividad ping6
- Capturas de tráfico (tcpdump)
- Reportes JSON por host

---

### **Punto 6: Conectividad IPv6 Total** ✅
**Configurado en:**
- `roles/debian-ipv6-router/tasks/main.yml`
- `inventory/hosts.yml` - Rutas estáticas

**Subredes:**
- `2025:db8:101::/64` - Red principal (Debian Router)
- `2025:db8:100::/64` - Laboratorio

**Routing:**
- IPv6 forwarding habilitado en Debian Router
- Rutas estáticas configuradas
- physical-router con `GigabitEthernet0/1: 2025:db8:101::2/64`

---

### **Punto 7-8: Firewall con Firewalld** ✅
**Archivos:**
- `roles/firewall-policy/tasks/main.yml`
- `roles/firewall-policy/handlers/main.yml`

**Reglas Asimétricas:**
- ✅ **Permitido:** `2025:db8:100::/64` → `2025:db8:101::/64`
- ❌ **Bloqueado:** `2025:db8:101::/64` → `2025:db8:100::/64` (nuevas conexiones)
- ✅ **Permitido:** Respuestas (established/related)

**Zonas:**
- `internal` - LAN (101::/64)
- `external` - Laboratorio (100::/64)

---

### **Punto 9: Laboratorio y Apps** ⚠️
**Estado:** Pendiente de implementación manual

**Tareas pendientes:**
- Instalar SteamCMD en VMs del laboratorio
- Configurar servidores dedicados:
  - Left 4 Dead
  - Counter Strike
- Abrir puertos en firewall
- Validar conectividad con `nmap`

**Recomendación:** Crear rol `roles/lab-gaming`

---

### **Punto 10: Hardening de Seguridad** ✅
**Archivos:**
- `roles/hardening/tasks/main.yml`
- `roles/hardening/handlers/main.yml`

**Configuraciones:**
- Usuario `operator` con permisos limitados
- Usuario `ansible` con NOPASSWD sudo
- Fail2ban activo
- Kernel hardening (sysctl)
- Logrotate para logs de Ansible

**Aplicado a:** `linux_servers` (no Windows ni IOS)

---

### **Punto 11: SSH Seguro** ✅
**Archivos:**
- `roles/ssh-hardening/tasks/main.yml`
- `roles/ssh-hardening/handlers/main.yml`

**Configuraciones:**
- `PermitRootLogin no`
- `PasswordAuthentication no`
- `PubkeyAuthentication yes`
- Protocol 2 únicamente
- X11Forwarding deshabilitado

**Aplicado a:** `linux_servers` únicamente

**Nota:** Los dispositivos de red (IOS) usan `network_cli`, no SSH tradicional

---

### **Punto 12: Evidencias Mínimas** ✅
**Validación automática:**
```bash
ansible-playbook playbooks/validate_connectivity.yml
```

**Evidencias requeridas:**
- ✅ Direccionamiento IPv6 (todos los hosts)
- ✅ Tablas de rutas
- ✅ Conectividad entre nodos (ping6)
- ✅ Capturas de tráfico (PCAP)
- ✅ Running-config (Cisco IOS)
- ✅ Reportes JSON estructurados

---

## 📊 Inventario Reorganizado

### **Grupos Principales:**

#### **network_devices** (Cisco IOS)
- `physical-router` - Router físico con `GigabitEthernet0/1: 2025:db8:101::2/64`
- `ios-core-router` - Router IOS virtualizado
- `access-switch` - Switch de acceso

**Conexión:** `network_cli` (no SSH tradicional)  
**Roles aplicables:** `ios-basic-config`

#### **linux_servers** (SSH + Hardening)
- `debian-router` - Router Debian IPv6
- `ubuntu-pc` - PC Ubuntu (laboratorio)

**Roles aplicables:** 
- `debian-ipv6-router`
- `firewall-policy`
- `hardening`
- `ssh-hardening`
- `evidence-collector`

#### **windows_hosts** (WinRM)
- `windows-pc` - PC Windows

**Roles aplicables:** Limitados (sin hardening Linux)

---

## 🚀 Flujo de Ejecución Completo

### **1. Preparación Inicial**
```bash
# Clonar repositorio
git clone <repo>
cd ansible

# Bootstrap
./bootstrap_control_vm.sh
ansible-playbook playbooks/bootstrap_control.yml
```

### **2. Configurar Vault**
```bash
cp group_vars/all/vault.yml.template group_vars/all/vault.yml
vim group_vars/all/vault.yml  # Editar credenciales
ansible-vault encrypt group_vars/all/vault.yml
echo "mi_password_vault" > .vault_pass
chmod 600 .vault_pass
```

### **3. Actualizar Inventario**
```bash
vim inventory/hosts.yml
# Cambiar IP de physical-router por la real
# Verificar IPs de todos los hosts
```

### **4. Copiar Clave SSH a Hosts**
```bash
cat ~/.ssh/id_rsa_ansible.pub
ssh-copy-id -i ~/.ssh/id_rsa_ansible.pub ansible@debian-router
ssh-copy-id -i ~/.ssh/id_rsa_ansible.pub ansible@ubuntu-pc
```

### **5. Ejecución por Fases**
```bash
# Fase 1: Configurar dispositivos de red
ansible-playbook playbooks/site.yml --tags network

# Fase 2: Crear VMs
ansible-playbook playbooks/site.yml --tags vm_creation

# Fase 3: Configurar router y servicios
ansible-playbook playbooks/site.yml --tags debian,services

# Fase 4: Firewall y seguridad
ansible-playbook playbooks/site.yml --tags firewall,security

# Fase 5: Evidencias
ansible-playbook playbooks/site.yml --tags evidence
```

### **6. Ejecución Completa**
```bash
ansible-playbook playbooks/site.yml
```

### **7. Validación**
```bash
ansible-playbook playbooks/validate_connectivity.yml
ls -la evidence/configs/
ls -la evidence/pings/
ls -la evidence/reports/
```

---

## 🔍 Verificaciones Post-Implementación

### **Verificar Vault**
```bash
# No debe haber credenciales en texto plano
grep -r "qwe123" inventory/
# Solo debe aparecer en vault.yml (cifrado)

# Ver Vault cifrado
cat group_vars/all/vault.yml
# Debe mostrar $ANSIBLE_VAULT;...

# Editar Vault
ansible-vault edit group_vars/all/vault.yml
```

### **Verificar VMs Idempotentes**
```bash
# Ejecutar dos veces, no debe duplicar VMs
ansible-playbook playbooks/site.yml --tags vm_creation
ansible-playbook playbooks/site.yml --tags vm_creation
# Segunda ejecución debe reutilizar VMs existentes
```

### **Verificar Firewall**
```bash
# Conectar a debian-router
ssh ansible@172.17.25.126

# Ver zonas activas
sudo firewall-cmd --get-active-zones

# Ver reglas
sudo firewall-cmd --list-all --zone=internal
sudo firewall-cmd --list-all --zone=external
```

### **Verificar SSH Hardening**
```bash
ssh ansible@debian-router
grep "PasswordAuthentication no" /etc/ssh/sshd_config
grep "PermitRootLogin no" /etc/ssh/sshd_config
sudo fail2ban-client status sshd
```

### **Verificar Evidencias**
```bash
# Debe haber archivos en cada directorio
find evidence/ -type f
# Verificar reportes JSON
cat evidence/reports/debian-router_report.json | jq
```

### **Verificar Conectividad IPv6**
```bash
# Desde debian-router
ssh ansible@172.17.25.126
ping6 -c 4 2025:db8:101::2  # physical-router
ping6 -c 4 2025:db8:101::10 # ubuntu-pc
ping6 -c 4 2025:db8:100::2  # laboratorio
```

---

## 📋 Checklist de Validación

- [ ] Bootstrap ejecutado sin errores
- [ ] Collections instaladas (`ansible-galaxy collection list`)
- [ ] Vault cifrado y funcionando
- [ ] VMs creadas (o reutilizadas si existen)
- [ ] Debian Router configurado con IPv6
- [ ] physical-router con interfaz `2025:db8:101::2/64`
- [ ] Firewall con reglas asimétricas
- [ ] SSH hardening aplicado (solo Linux)
- [ ] Fail2ban activo
- [ ] Evidencias generadas en `evidence/`
- [ ] Reportes JSON creados
- [ ] Conectividad IPv6 funcional
- [ ] Documentación completa

---

## 🆘 Troubleshooting

### **Error: "vault password file not found"**
```bash
echo "tu_password" > .vault_pass
chmod 600 .vault_pass
```

### **Error: "Collection not found"**
```bash
ansible-galaxy collection install -r requirements.yml --force
```

### **Error: "No module named 'pyvmomi'"**
```bash
pip3 install --user -r requirements-pip.txt
```

### **Error: "Permission denied (publickey)"**
```bash
ssh-copy-id -i ~/.ssh/id_rsa_ansible.pub ansible@<host>
```

### **Error: "VM already exists"**
Los roles ahora son idempotentes. No es un error, simplemente reutiliza la VM.

---

## 📚 Documentación Adicional

- `BOOTSTRAP_README.md` - Guía de bootstrap y uso
- `README.md` - Documentación original del proyecto
- `group_vars/all/vault.yml.template` - Template de Vault

---

## 🎓 Notas Importantes

### **Separación de Hosts**
- **network_devices:** Cisco IOS, usan `network_cli`
- **linux_servers:** Debian/Ubuntu, usan SSH
- **windows_hosts:** Windows, usan WinRM

### **physical-router**
- **NO es un servidor Linux**
- **NO recibe hardening SSH/Linux**
- **Solo configuración via `ios-basic-config`**
- **IP de gestión:** Ajustar en `inventory/hosts.yml`
- **Interfaz activa:** `GigabitEthernet0/1` con `2025:db8:101::2/64`

### **Variables de Vault**
Todas las credenciales deben estar en `vault.yml`:
- ESXi/vCenter
- Cisco IOS
- SSH keys
- FTP/HTTP

### **Evidencias**
Se generan automáticamente al final de cada ejecución.
Validar con: `ansible-playbook playbooks/validate_connectivity.yml`

---

## ✅ Criterios de Éxito

1. **Bootstrap:** Ejecutar `bootstrap_control_vm.sh` → OK
2. **Vault:** Credenciales cifradas, no en texto plano
3. **VMs:** Idempotentes, no duplicadas
4. **Firewall:** Reglas asimétricas funcionando
5. **SSH:** Solo autenticación por llave
6. **Evidencias:** Archivos generados en `evidence/`
7. **IPv6:** Conectividad total entre subredes

---

**Última actualización:** 2025-11-04  
**Estado:** ✅ 11/12 Puntos Implementados (Punto 9 pendiente manual)

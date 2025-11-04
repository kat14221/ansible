# 🚀 Quick Start - Instalación desde Cero

## 📋 Objetivo

Configurar **desde cero** una VM de control Ansible y ejecutar todo el proyecto VMWARE-101001 sin configuración manual.

---

## 🖥️ Paso 1: Crear VM de Control

### **Requisitos de la VM:**
- **OS:** Debian 12 o Ubuntu 22.04/24.04 LTS
- **RAM:** 2 GB mínimo (4 GB recomendado)
- **Disco:** 20 GB
- **CPU:** 2 cores
- **Red:** Conectada a internet (para descargar paquetes)

### **Instalación del OS:**
1. Crear VM en tu hypervisor (VirtualBox, VMware, ESXi, etc.)
2. Instalar Debian 12 o Ubuntu 24.04
3. Durante instalación:
   - Usuario: `ansible` (⚠️ importante)
   - Contraseña: la que prefieras
   - Hostname: `ansible-control`
   - Instalar **SSH Server**
   - Instalar **Standard System Utilities**

### **Post-Instalación:**
```bash
# Actualizar sistema
sudo apt update
sudo apt upgrade -y

# Instalar git
sudo apt install -y git

# Configurar sudo sin password (opcional, para comodidad)
echo "ansible ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/ansible
```

---

## 📥 Paso 2: Clonar el Proyecto

```bash
# Ir al directorio home
cd ~

# Clonar el proyecto
git clone <URL_DE_TU_REPOSITORIO> ansible
cd ansible

# O si ya tienes los archivos, copiarlos a la VM
# scp -r /ruta/local/ansible/ ansible@<IP-VM>:~/
```

---

## ⚙️ Paso 3: Ejecutar Bootstrap

Este script instala **TODO** automáticamente:

```bash
# Dar permisos de ejecución
chmod +x bootstrap_control_vm.sh

# Ejecutar bootstrap (instala Ansible, Python, collections, etc.)
./bootstrap_control_vm.sh
```

**El script instalará:**
- ✅ Python 3 y pip
- ✅ Ansible
- ✅ Git, sshpass, build-essential
- ✅ Collections de Ansible (community.vmware, cisco.ios, etc.)
- ✅ Dependencias Python (pyvmomi, netaddr, passlib, etc.)
- ✅ Estructura de directorios `evidence/`

**Duración aproximada:** 5-10 minutos

---

## 🔧 Paso 4: Post-Bootstrap

```bash
# Ejecutar playbook de post-instalación
ansible-playbook playbooks/bootstrap_control.yml
```

**Este playbook:**
- ✅ Crea directorios de evidencias
- ✅ Verifica instalación de collections
- ✅ Genera par de llaves SSH
- ✅ Configura `ansible.cfg`

---

## 🔐 Paso 5: Configurar Vault (Credenciales)

### **5.1 Crear Vault desde Template:**
```bash
# Copiar template
cp group_vars/all/vault.yml.template group_vars/all/vault.yml
```

### **5.2 Editar Credenciales Reales:**
```bash
vim group_vars/all/vault.yml
```

**Cambiar estos valores:**
```yaml
# ESXi/vCenter
vault_vcenter_hostname: "172.17.25.1"  # Tu IP de ESXi
vault_vcenter_username: "root"         # Tu usuario de ESXi
vault_vcenter_password: "TU_PASSWORD"  # ⚠️ Tu password real

# Cisco IOS
vault_cisco_user: "admin"              # Tu usuario Cisco
vault_cisco_password: "TU_PASSWORD"    # ⚠️ Tu password real

# SSH Key (generar después)
vault_ansible_ssh_public_key: ""       # Se llenará después
```

### **5.3 Cifrar el Vault:**
```bash
# Cifrar con Ansible Vault
ansible-vault encrypt group_vars/all/vault.yml

# Te pedirá una contraseña (recuérdala, la necesitarás)
# Ejemplo: "mi_password_vault_123"
```

### **5.4 Guardar Password del Vault:**
```bash
# Crear archivo con password (para no escribirla cada vez)
echo "mi_password_vault_123" > .vault_pass

# Proteger el archivo
chmod 600 .vault_pass

# ⚠️ NUNCA commitear este archivo a Git (ya está en .gitignore)
```

---

## 📝 Paso 6: Actualizar Inventario

### **6.1 Editar IPs de Gestión:**
```bash
vim inventory/hosts.yml
```

**Actualizar estas líneas:**

```yaml
# Línea 121: IP de gestión del router físico
ansible_host: "192.168.1.1"  # ⚠️ Cambiar por IP real

# Línea 142: IP de gestión del switch 3
ansible_host: "192.168.1.3"  # ⚠️ Cambiar por IP real

# Línea 7: IP de ESXi (si es diferente)
ansible_host: 172.17.25.1    # ⚠️ Verificar
```

### **6.2 Verificar IPs de VMs:**
```yaml
# debian-router (línea 22)
ansible_host: "172.17.25.126"  # ⚠️ Verificar IP de gestión

# ubuntu-pc (línea 76)
ansible_host: "2025:db8:101::10"  # ✅ OK (IPv6)

# windows-pc (línea 89)
ansible_host: "2025:db8:101::11"  # ✅ OK (IPv6)
```

---

## 🔑 Paso 7: Configurar SSH Keys

### **7.1 Generar Clave SSH (si no existe):**
```bash
# Ver clave pública generada por bootstrap
cat ~/.ssh/id_rsa_ansible.pub
```

### **7.2 Copiar a Vault:**
```bash
# Editar Vault
ansible-vault edit group_vars/all/vault.yml

# Añadir la clave pública:
vault_ansible_ssh_public_key: "ssh-rsa AAAAB3NzaC1yc2EA... ansible@ansible-control"
```

### **7.3 Copiar Clave a Hosts Remotos:**

**Cuando las VMs estén creadas y configuradas:**
```bash
# Copiar a debian-router
ssh-copy-id -i ~/.ssh/id_rsa_ansible.pub ansible@172.17.25.126

# Copiar a ubuntu-pc (después de tener IPv6)
ssh-copy-id -i ~/.ssh/id_rsa_ansible.pub ansible@2025:db8:101::10

# Verificar acceso
ssh -i ~/.ssh/id_rsa_ansible ansible@172.17.25.126
```

---

## ✅ Paso 8: Validar Configuración

```bash
# Verificar sintaxis del inventario
ansible-inventory -i inventory/hosts.yml --list

# Verificar conexión a localhost
ansible localhost -m ping

# Verificar collections instaladas
ansible-galaxy collection list

# Verificar dependencias Python
pip3 list | grep -E 'pyvmomi|netaddr|passlib'

# Verificar Vault
ansible-vault view group_vars/all/vault.yml
```

---

## 🚀 Paso 9: Ejecutar Proyecto (Primera Vez)

### **Opción A: Ejecución Completa**
```bash
ansible-playbook playbooks/site.yml
```

### **Opción B: Ejecución por Fases (Recomendado para primera vez)**

#### **Fase 1: Configurar Dispositivos de Red**
```bash
ansible-playbook playbooks/site.yml --tags network
```
**Qué hace:**
- Configura physical-router (Cisco IOS)
- Configura switch-3
- Aplica configuración IPv6

**Validar:**
```bash
# Conectar al router físico y verificar
ssh admin@192.168.1.1
show ipv6 interface brief
show ipv6 route
```

---

#### **Fase 2: Crear VMs en ESXi**
```bash
ansible-playbook playbooks/site.yml --tags vm_creation
```
**Qué hace:**
- Crea VM debian-router (si no existe)
- Crea VM ubuntu-pc (si no existe)
- Crea VM windows-pc (si no existe)

**⚠️ IMPORTANTE - Pasos Manuales:**
1. **Instalar OS en las VMs:**
   - Conectar a ESXi Web UI: `https://172.17.25.1`
   - Instalar Debian 12 en `vm-debian-router`
   - Instalar Ubuntu 24.04 en `vm-ubuntu-pc`
   - Instalar Windows 11 en `vm-windows-pc`

2. **Configurar usuario `ansible` en cada VM:**
   ```bash
   # En debian-router y ubuntu-pc
   sudo adduser ansible
   sudo usermod -aG sudo ansible
   echo "ansible ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/ansible
   ```

3. **Copiar SSH key:**
   ```bash
   # Desde VM de control
   ssh-copy-id ansible@172.17.25.126  # debian-router
   ```

---

#### **Fase 3: Configurar Debian Router**
```bash
ansible-playbook playbooks/site.yml --tags debian,services
```
**Qué hace:**
- Configura IPv6 en debian-router
- Instala y configura RADVD
- Instala y configura DHCPv6
- Despliega servicios HTTP/FTP
- Configura routing IPv6

**Validar:**
```bash
# Conectar a debian-router
ssh ansible@172.17.25.126

# Verificar IPv6
ip -6 addr show
ip -6 route show

# Verificar servicios
systemctl status radvd
systemctl status isc-dhcp-server6
systemctl status apache2

# Ping a physical-router
ping6 -c 4 2025:db8:101::2
```

---

#### **Fase 4: Firewall y Seguridad**
```bash
ansible-playbook playbooks/site.yml --tags firewall,security
```
**Qué hace:**
- Configura firewalld con reglas asimétricas
- Aplica SSH hardening
- Configura fail2ban
- Kernel hardening

**Validar:**
```bash
ssh ansible@172.17.25.126

# Verificar firewall
sudo firewall-cmd --state
sudo firewall-cmd --get-active-zones
sudo firewall-cmd --list-all --zone=internal

# Verificar SSH hardening
grep "PasswordAuthentication no" /etc/ssh/sshd_config

# Verificar fail2ban
sudo fail2ban-client status
```

---

#### **Fase 5: Tests y Evidencias**
```bash
ansible-playbook playbooks/site.yml --tags tests,evidence,reports
```
**Qué hace:**
- Ejecuta pruebas de conectividad
- Captura tráfico IPv6
- Recolecta evidencias
- Genera informes técnicos
- Configura carpetas compartidas Samba

**Validar:**
```bash
# Ver evidencias generadas
ls -la evidence/configs/
ls -la evidence/pings/
ls -la evidence/reports/
ls -la evidence/technical_reports/

# Abrir índice de informes
firefox evidence/technical_reports/index.html

# Acceder a carpeta compartida (desde Windows)
\\172.17.25.126\reports
```

---

## 📊 Paso 10: Verificar Resultado Final

### **10.1 Conectividad IPv6:**
```bash
# Desde debian-router
ssh ansible@172.17.25.126

# Ping a physical-router
ping6 -c 4 2025:db8:101::2

# Ping a ubuntu-pc
ping6 -c 4 2025:db8:101::10

# Ping a red laboratorio (vía physical-router)
ping6 -c 4 2025:db8:100::2
```

### **10.2 Firewall Asimétrico:**
```bash
# Desde debian-router (101::/64)
ping6 -c 4 2025:db8:100::2  # ❌ Debe FALLAR (bloqueado por firewall)

# Desde red laboratorio (100::/64) hacia debian-router
# Debe FUNCIONAR (permitido por firewall)
```

### **10.3 Servicios HTTP:**
```bash
# Desde cualquier host con IPv6
curl -6 http://[2025:db8:101::1]  # HTTP en debian-router

# Desde navegador
http://[2025:db8:101::1]
```

### **10.4 Carpetas Compartidas:**
```bash
# Desde Windows
\\172.17.25.126\reports

# Ver informes técnicos
\\172.17.25.126\reports\debian-router_technical_report.html
```

---

## 🔄 Paso 11: Re-Ejecutar (Idempotencia)

```bash
# Ejecutar nuevamente (debe ser idempotente)
ansible-playbook playbooks/site.yml

# Verificar que NO duplica VMs
# Verificar que NO reconfigura lo que ya está bien
```

**Comportamiento esperado:**
- ✅ VMs existentes: **REUTILIZADAS** (no se crean nuevas)
- ✅ Configuraciones: **VERIFICADAS** (solo cambia lo necesario)
- ✅ Sin errores
- ✅ Ejecución más rápida (skip de tareas ya completadas)

---

## 🆘 Troubleshooting

### **Error: "vault password file not found"**
```bash
# Crear .vault_pass
echo "tu_password_vault" > .vault_pass
chmod 600 .vault_pass
```

### **Error: "Collection not found"**
```bash
# Reinstalar collections
ansible-galaxy collection install -r requirements.yml --force
```

### **Error: "No module named 'pyvmomi'"**
```bash
# Reinstalar dependencias Python
pip3 install --user -r requirements-pip.txt
```

### **Error: "Permission denied (publickey)"**
```bash
# Copiar SSH key nuevamente
ssh-copy-id -i ~/.ssh/id_rsa_ansible.pub ansible@<HOST>

# O usar password temporalmente
ansible-playbook playbooks/site.yml -k  # -k pide password SSH
```

### **Error al conectar a ESXi**
```bash
# Verificar credenciales en Vault
ansible-vault view group_vars/all/vault.yml

# Verificar conectividad
ping 172.17.25.1
curl -k https://172.17.25.1
```

### **debian-router no tiene IPv6**
```bash
# Conectar y configurar manualmente interfaz
ssh ansible@172.17.25.126
sudo ip -6 addr add 2025:db8:101::1/64 dev ens192
sudo ip link set ens192 up

# Re-ejecutar playbook
ansible-playbook playbooks/site.yml --tags debian
```

---

## 📋 Checklist de Validación Final

- [ ] VM de control creada con Debian/Ubuntu
- [ ] Bootstrap ejecutado sin errores
- [ ] Collections de Ansible instaladas
- [ ] Vault creado y cifrado
- [ ] .vault_pass configurado
- [ ] IPs actualizadas en inventario
- [ ] SSH keys generadas y copiadas
- [ ] physical-router configurado (IPv6)
- [ ] VMs creadas en ESXi
- [ ] OS instalado en todas las VMs
- [ ] debian-router con IPv6 funcional
- [ ] Firewall configurado (reglas asimétricas)
- [ ] SSH hardening aplicado
- [ ] Evidencias generadas
- [ ] Informes técnicos creados
- [ ] Carpetas compartidas accesibles
- [ ] Conectividad IPv6 completa
- [ ] Proyecto idempotente (re-ejecutable)

---

## ⏱️ Tiempo Estimado Total

| Fase | Tiempo | Descripción |
|------|--------|-------------|
| 1. Crear VM de control | 15 min | Instalación OS |
| 2. Clonar proyecto | 5 min | Git clone |
| 3. Bootstrap | 10 min | Instalación automática |
| 4. Configurar Vault | 10 min | Credenciales |
| 5. Actualizar inventario | 10 min | IPs |
| 6. SSH keys | 5 min | Generar y copiar |
| 7. Configurar dispositivos red | 15 min | Cisco IOS |
| 8. Crear VMs | 10 min | ESXi |
| 9. Instalar OS en VMs | 45 min | Manual |
| 10. Ejecutar playbooks | 30 min | Automatizado |
| 11. Validación | 15 min | Tests |
| **TOTAL** | **~2.5 horas** | Incluyendo instalaciones manuales |

---

## 🎯 Próximos Pasos

Una vez completado:
1. ✅ Generar informes adicionales: `ansible-playbook playbooks/generate_reports.yml`
2. ✅ Validar conectividad: `ansible-playbook playbooks/validate_connectivity.yml`
3. ✅ Revisar documentación: `TOPOLOGIA_RED.md`, `GUIA_INFORMES.md`
4. ✅ Configurar laboratorio de apps (Punto 9 - opcional)

---

**¿Listo para empezar? Sigue esta guía paso a paso y tendrás todo funcionando desde cero. 🚀**

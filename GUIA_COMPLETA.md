# 📖 Guía Completa - Proyecto Ansible IPv6 VMWARE-101001

## 🎯 Objetivo

Esta guía te llevará paso a paso desde la instalación inicial hasta la ejecución completa del proyecto de red IPv6 académica automatizada con Ansible.

## 📋 Requisitos Previos

### Hardware/Infraestructura
- **ESXi Host**: 168.121.48.254 (accesible)
- **VM de Control**: Debian 12 o Ubuntu 22.04+ dentro del ESXi
- **Router Físico**: Cisco IOS con IPv6
- **Conectividad**: Acceso a internet para descargas

### Software
- Sistema operativo Linux (Debian/Ubuntu)
- Acceso SSH a la VM de control
- Navegador web para acceso al ESXi

## 🚀 Instalación Desde Cero

### Paso 1: Preparar VM de Control

#### 1.1 Crear VM en ESXi
1. Acceder a ESXi: `https://168.121.48.254:10101/ui/#/login`
2. Usuario: `root` / Contraseña: `qwe123$`
3. Crear nueva VM:
   - **OS**: Debian 12 o Ubuntu 24.04
   - **RAM**: 4 GB mínimo
   - **Disco**: 20 GB
   - **Red**: VM Network (para gestión)

#### 1.2 Instalar Sistema Operativo
```bash
# Durante la instalación:
# - Usuario: ansible
# - Hostname: ansible-control
# - Instalar SSH Server
# - Instalar utilidades estándar
```

#### 1.3 Configuración Post-Instalación
```bash
# Actualizar sistema
sudo apt update && sudo apt upgrade -y

# Configurar sudo sin contraseña (opcional)
echo "ansible ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/ansible

# Instalar git
sudo apt install -y git
```

### Paso 2: Obtener el Proyecto

```bash
# Clonar repositorio
cd ~
git clone <URL_DEL_REPOSITORIO> ansible-ipv6
cd ansible-ipv6

# O transferir archivos si ya los tienes
# scp -r /ruta/local/proyecto/ ansible@<IP-VM>:~/ansible-ipv6/
```

### Paso 3: Bootstrap Automático

```bash
# Ejecutar bootstrap (instala todo automáticamente)
chmod +x bootstrap_control_vm.sh
./bootstrap_control_vm.sh

# Post-bootstrap
ansible-playbook playbooks/bootstrap_control.yml
```

**El bootstrap instala:**
- ✅ Python 3 y pip
- ✅ Ansible y collections
- ✅ Dependencias (pyvmomi, netaddr, etc.)
- ✅ Estructura de directorios
- ✅ Configuración básica

### Paso 4: Configuración de Credenciales

#### 4.1 Configurar Vault Automáticamente
```bash
# Setup automático (recomendado)
chmod +x scripts/*.sh
./scripts/quick_setup.sh
```

El script te pedirá:
- IP de ESXi/vCenter
- Credenciales de ESXi
- Credenciales de Cisco IOS
- Contraseña del Vault

#### 4.2 Configuración Manual (alternativa)
```bash
# Crear vault desde template
cp group_vars/all/vault.yml.template group_vars/all/vault.yml

# Editar credenciales
vim group_vars/all/vault.yml

# Cifrar vault
ansible-vault encrypt group_vars/all/vault.yml

# Crear archivo de contraseña
echo "tu_password_vault" > .vault_pass
chmod 600 .vault_pass
```

### Paso 5: Actualizar Inventario

```bash
# Editar inventario con IPs reales
vim inventory/hosts.yml

# Actualizar estas líneas críticas:
# - ansible_host del physical-router (línea ~121)
# - ansible_host del debian-router (línea ~22)
# - Verificar IP del ESXi (línea ~7)
```

### Paso 6: Configurar SSH Keys

```bash
# Generar clave SSH (si no existe)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_ansible -N ""

# Copiar a hosts (cuando estén disponibles)
./scripts/copy_ssh_keys.sh

# O manualmente:
ssh-copy-id -i ~/.ssh/id_rsa_ansible.pub ansible@172.17.25.126
```

## 🎬 Ejecución del Proyecto

### Opción 1: Ejecución Completa (Recomendada)

```bash
# Ejecutar todo el proyecto de una vez
ansible-playbook playbooks/site.yml -vvv

# Duración aproximada: 30-45 minutos
# Incluye: VMs, configuración, servicios, tests, evidencias
```

### Opción 2: Ejecución por Fases

#### Fase 1: Configurar Dispositivos de Red
```bash
ansible-playbook playbooks/site.yml --tags network -vvv
```
**Qué hace:**
- Configura router físico Cisco IOS
- Aplica configuración IPv6
- Configura interfaces y routing

**Validar:**
```bash
# Conectar al router físico
ssh ansible@2025:db8:101::2
show ipv6 interface brief
show ipv6 route
```

#### Fase 2: Crear VMs en ESXi
```bash
ansible-playbook playbooks/create_vms.yml -vvv
```
**Qué hace:**
- Crea VM debian-router (si no existe)
- Crea VM ubuntu-pc (si no existe)
- Crea VM windows-pc (si no existe)
- Enciende todas las VMs automáticamente
- Monta ISOs para instalación

**⚠️ Pasos Manuales Requeridos:**
1. **Instalar OS en las VMs** (vía consola ESXi)
2. **Configurar usuario `ansible`** en cada VM
3. **Copiar SSH keys** a las VMs Linux

#### Fase 3: Configurar Router Debian
```bash
ansible-playbook playbooks/site.yml --tags debian,services -vvv
```
**Qué hace:**
- Configura IPv6 en debian-router
- Instala RADVD (Router Advertisement)
- Configura DHCPv6
- Despliega servicios HTTP/FTP
- Habilita IPv6 forwarding

**Validar:**
```bash
ssh ansible@172.17.25.126

# Verificar IPv6
ip -6 addr show
ip -6 route show

# Verificar servicios
systemctl status radvd
systemctl status isc-dhcp-server6
systemctl status apache2

# Test conectividad
ping6 -c 4 2025:db8:101::2  # Router físico
ping6 -c 4 2025:db8:101::10 # Ubuntu PC (si está listo)
```

#### Fase 4: Firewall y Seguridad
```bash
ansible-playbook playbooks/site.yml --tags firewall,security -vvv
```
**Qué hace:**
- Configura firewalld con reglas asimétricas
- Aplica SSH hardening
- Configura fail2ban
- Implementa kernel hardening

**Validar:**
```bash
ssh ansible@172.17.25.126

# Verificar firewall
sudo firewall-cmd --state
sudo firewall-cmd --get-active-zones
sudo firewall-cmd --list-all --zone=internal

# Verificar SSH hardening
grep "PasswordAuthentication no" /etc/ssh/sshd_config
sudo fail2ban-client status
```

#### Fase 5: Tests y Evidencias
```bash
ansible-playbook playbooks/site.yml --tags tests,evidence,reports -vvv
```
**Qué hace:**
- Ejecuta pruebas de conectividad IPv6
- Captura tráfico de red
- Recolecta configuraciones
- Genera reportes técnicos
- Configura carpetas compartidas

**Validar:**
```bash
# Ver evidencias generadas
ls -la evidence/configs/
ls -la evidence/pings/
ls -la evidence/pcaps/
ls -la evidence/reports/
ls -la evidence/technical_reports/

# Abrir reportes
firefox evidence/technical_reports/index.html
```

### Opción 3: Playbooks Individuales

```bash
# Crear todas las VMs
ansible-playbook playbooks/create_vms.yml -vvv

# Solo configurar IOS
ansible-playbook playbooks/configure_ios_router.yml -vvv

# Solo configurar Debian
ansible-playbook playbooks/configure_debian_ipv6.yml -vvv

# Solo servicios
ansible-playbook playbooks/deploy_http_service.yml -vvv

# Solo tests
ansible-playbook playbooks/test_connectivity.yml -vvv
```

## 🔍 Verificación y Validación

### Verificar Conectividad IPv6

#### Desde Debian Router
```bash
ssh ansible@172.17.25.126

# Verificar interfaces
ip -6 addr show

# Verificar rutas
ip -6 route show

# Tests de conectividad
ping6 -c 4 2025:db8:101::2   # Router físico
ping6 -c 4 2025:db8:101::10  # Ubuntu PC
ping6 -c 4 2025:db8:101::11  # Windows PC
```

#### Desde Ubuntu PC
```bash
ssh ansible@2025:db8:101::10

# Verificar configuración automática
ip -6 addr show | grep 2025:db8:101

# Test conectividad
ping6 -c 4 2025:db8:101::1   # Gateway (Debian Router)
ping6 -c 4 2025:db8:101::11  # Windows PC
ping6 -c 4 2025:db8:101::2   # Router físico
```

#### Desde Windows PC
```powershell
# Abrir PowerShell como Administrador
ipconfig /all | findstr "2025:db8:101"

# Test conectividad
ping -6 2025:db8:101::1   # Gateway
ping -6 2025:db8:101::10  # Ubuntu PC
```

### Verificar Servicios

#### HTTP Service
```bash
# Desde cualquier host con IPv6
curl -6 http://[2025:db8:101::1]

# Desde navegador
http://[2025:db8:101::1]
```

#### FTP Service
```bash
# Test FTP
ftp -6 2025:db8:101::1
# Usuario: ftpuser
# Contraseña: ftppass123
```

#### Carpetas Compartidas (Samba)
```bash
# Desde Windows
\\172.17.25.126\reports

# Ver reportes técnicos
\\172.17.25.126\reports\index.html
```

### Verificar Firewall Asimétrico

```bash
# Desde debian-router (2025:db8:101::/64)
# Hacia red laboratorio (2025:db8:100::/64)
ping6 -c 4 2025:db8:100::2  # ❌ Debe FALLAR (bloqueado)

# Desde red laboratorio hacia debian-router
# Debe FUNCIONAR (permitido por firewall)
```

## 🆘 Troubleshooting

### Problemas Comunes

#### Error: "vault password file not found"
```bash
echo "tu_password_vault" > .vault_pass
chmod 600 .vault_pass
```

#### Error: "The vault-ids default,default are available to encrypt"
Este error ocurre cuando ansible-vault no puede encontrar el vault-id correcto. Solución:

```bash
# Opción 1: Usar el script de solución
./scripts/fix_vault_error.sh

# Opción 2: Cifrar manualmente con vault-id
ansible-vault encrypt group_vars/all/vault.yml --vault-id default@.vault_pass

# Opción 3: Recrear el vault completamente
rm -f group_vars/all/vault.yml .vault_pass
./scripts/setup_vault.sh
```

#### Error: "Collection not found"
```bash
ansible-galaxy collection install -r requirements.yml --force
```

#### Error: "No module named 'pyvmomi'"
```bash
pip3 install --user pyvmomi
# O re-ejecutar bootstrap
./bootstrap_control_vm.sh
```

#### Error: "Permission denied (publickey)"
```bash
# Copiar SSH key nuevamente
ssh-copy-id -i ~/.ssh/id_rsa_ansible.pub ansible@<HOST>

# O usar password temporalmente
ansible-playbook playbooks/site.yml -k
```

#### Error al conectar a ESXi
```bash
# Verificar credenciales
ansible-vault view group_vars/all/vault.yml

# Verificar conectividad
ping 168.121.48.254
curl -k https://168.121.48.254
```

#### VMs no obtienen IPv6
```bash
# En debian-router, verificar servicios
systemctl status radvd
systemctl status isc-dhcp-server6

# Ver logs
journalctl -u radvd -n 50
journalctl -u isc-dhcp-server6 -n 50

# En el cliente, forzar renovación
sudo dhclient -6 -r ens160
sudo dhclient -6 ens160
```

### Debug Avanzado

#### Ver logs detallados
```bash
# Logs de Ansible
tail -f evidence/logs/ansible.log

# Ejecutar con máximo verbose
ansible-playbook playbooks/site.yml -vvvv

# Debug de tareas específicas
ansible-playbook playbooks/site.yml --tags debian --check -vvv
```

#### Verificar inventario
```bash
# Listar todos los hosts
ansible-inventory -i inventory/hosts.yml --list

# Verificar conectividad
ansible all -m ping -i inventory/hosts.yml

# Test específico
ansible debian-router -m setup -i inventory/hosts.yml
```

## 📊 Evidencias y Reportes

### Estructura de Evidencias
```
evidence/
├── configs/           # Configuraciones guardadas
├── pings/            # Resultados de conectividad  
├── pcaps/            # Capturas de tráfico
├── services/         # Estados de servicios
├── reports/          # Reportes JSON
├── technical_reports/ # Reportes HTML
└── logs/             # Logs de Ansible
```

### Generar Reportes Adicionales
```bash
# Generar reportes técnicos
ansible-playbook playbooks/generate_reports.yml -vvv

# Validar conectividad completa
ansible-playbook playbooks/validate_connectivity.yml -vvv

# Capturar tráfico adicional
ansible-playbook playbooks/capture_traffic.yml -vvv
```

### Acceder a Reportes
```bash
# Reportes HTML locales
firefox evidence/technical_reports/index.html

# Reportes vía Samba (desde Windows)
\\172.17.25.126\reports

# Reportes JSON para análisis
cat evidence/reports/debian-router_report.json | jq
```

## ✅ Checklist de Validación Final

- [ ] Bootstrap ejecutado sin errores
- [ ] Collections de Ansible instaladas
- [ ] Vault configurado y cifrado
- [ ] SSH keys generadas y copiadas
- [ ] Inventario actualizado con IPs reales
- [ ] Router físico configurado (IPv6)
- [ ] VMs creadas en ESXi
- [ ] OS instalado en todas las VMs
- [ ] Debian router con IPv6 funcional
- [ ] RADVD y DHCPv6 funcionando
- [ ] Servicios HTTP/FTP accesibles
- [ ] Firewall configurado (reglas asimétricas)
- [ ] SSH hardening aplicado
- [ ] Evidencias generadas
- [ ] Reportes técnicos creados
- [ ] Carpetas compartidas accesibles
- [ ] Conectividad IPv6 completa
- [ ] Proyecto idempotente (re-ejecutable)

## 🎓 Próximos Pasos

Una vez completado exitosamente:

1. **Revisar evidencias** en `evidence/`
2. **Analizar capturas** con Wireshark
3. **Documentar resultados** para entrega académica
4. **Configurar laboratorio adicional** (opcional)
5. **Preparar presentación** del proyecto

## 📞 Soporte

Si encuentras problemas:
1. Revisa los logs: `evidence/logs/ansible.log`
2. Ejecuta con verbose: `-vvvv`
3. Consulta la sección de troubleshooting
4. Verifica la configuración en `CONFIGURACION.md`

---

**¡Proyecto listo para desplegar! 🚀**
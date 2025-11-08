# 🌐 Proyecto Ansible: Red IPv6 Académica VMWARE-101001

## 🎯 Descripción del Proyecto

Automatización completa con Ansible para desplegar una red IPv6 académica en la sala VMWARE-101001. 
Incluye configuración de VMs en ESXi, router Debian IPv6, servicios de red y equipos Cisco IOS.

**Características principales:**
- ✅ Despliegue automatizado de VMs en ESXi
- ✅ Configuración IPv6 con SLAAC/DHCPv6
- ✅ Router Debian con RADVD y servicios
- ✅ Configuración de equipos Cisco IOS
- ✅ Firewall y hardening de seguridad
- ✅ Generación automática de evidencias
- ✅ Reportes técnicos completos

## 📊 Arquitectura de Red

```
╔══════════════════════════════════════════════════════╗
║  Red Universidad: 172.17.x.x (Gestión)                  ║
║  ├─ ESXi Workstation: 172.17.25.1                        ║
║  └─ VM Debian Router (VM Network): 172.17.25.10         ║
╚══════════════════════════════════════════════════════╝

╔══════════════════════════════════════════════════════╗
║  Red Separada: 2025:DB8:100::/64                          ║
║  ├─ Router Físico Gi0/0/0: 2025:DB8:100::2               ║
║  └─ Switch + dispositivos (topología separada)          ║
╚══════════════════════════════════════════════════════╝
                    │
                    │ (Enrutamiento futuro)
                    │
╔══════════════════════════════════════════════════════╗
║  Red Laboratorio: 2025:DB8:101::/64 ⭐ PROYECTO ACTUAL    ║
║                                                            ║
║  Router Físico Gi0/0/1: 2025:DB8:101::2                   ║
║  Switch Físico: 2025:DB8:101::3                            ║
║      │                                                     ║
║      ├─ Workstation ESXi (Red Fernandez)                  ║
║      │   └─ ⭐ VM Debian Router: 2025:DB8:101::1 (GATEWAY)║
║      │      ├─ ens160: 172.17.25.10 (Gestión)            ║
║      │      └─ ens192: 2025:DB8:101::1 (Proyecto)       ║
║      │   ├─ VM Ubuntu: 2025:DB8:101::10                   ║
║      │   └─ VM Windows: 2025:DB8:101::11                  ║
║      │                                                     ║
║      ├─ Laptop → GNS3 (3 VMs)                             ║
║      └─ Access Point → Celular + Laptop Wi-Fi             ║
╚══════════════════════════════════════════════════════╝
```

## ⭐ Componente Principal: Debian Router (2 Interfaces)

### 🔹 **Interfaz 1 - Gestión** (ens160 - VM Network)
- **IPv4**: `172.17.25.10/24`
- **Gateway**: `172.17.25.1` (ESXi)
- **Uso**: Acceso de gestión desde red universidad

### 🔹 **Interfaz 2 - Proyecto** (ens192 - Red Fernandez)
- **IPv6**: `2025:DB8:101::1/64`
- **Rol**: Gateway principal de la red IPv6
- **Uso**: Router Advertisement + DHCPv6

### ⚙️ **Servicios Instalados**
- ✅ IPv6 Forwarding (Router)
- ✅ radvd (Router Advertisement)
- ✅ isc-dhcp-server6 (DHCPv6)
- ✅ Apache2 (HTTP)
- ✅ vsftpd (FTP)
- ✅ tcpdump/tshark (Análisis de tráfico)
- ✅ nftables (Firewall)

## 📋 Requisitos

### Hardware
- **ESXi Host**: 172.17.25.1 (accesible desde red universidad)
- **VM de Control**: Debian 12 o Ubuntu 24.04 LTS dentro del ESXi
- **Recursos mínimos VM Control**: 2 vCPU, 4GB RAM, 20GB disco

### Software (se instala automáticamente)
- **Sistema Operativo**: Ubuntu 24.04 LTS o Debian 12 (Bookworm)
- **Python**: 3.11+ (incluido en Ubuntu 24.04)
- **Ansible**: 2.16+ (core)
- **PyVmomi**: 8.0.3.0.1 (⚠️ versión específica requerida)
- **Collections**: 
  - community.vmware >= 4.0.0
  - cisco.ios >= 6.0.0
  - ansible.netcommon >= 6.0.0
  - ansible.posix >= 1.5.0
  - ansible.utils >= 3.0.0

### Verificación de Dependencias
```bash
# Verificar todas las dependencias
./verify_dependencies.sh

# Ver guía completa de dependencias
cat BUENAS_PRACTICAS_DEPENDENCIAS.md
```

## ⚡ Inicio Rápido

### 1. Preparar VM de Control
- Crear VM en ESXi: `https://168.121.48.254:10101/ui/#/login`
- Usuario ESXi: `root` / Contraseña: `qwe123$`
- Instalar Debian 12 o Ubuntu 24.04 en la VM

### 2. Clonar y Ejecutar Bootstrap
```bash
git clone <repositorio> ansible-ipv6
cd ansible-ipv6
chmod +x *.sh scripts/*.sh

# Instalar todas las dependencias (idempotente)
./bootstrap_control_vm.sh

# Verificar instalación
./verify_dependencies.sh

# Configurar VM de control
ansible-playbook playbooks/bootstrap_control.yml
```

> **💡 Nota sobre PyVmomi**: El script instala automáticamente `pyvmomi==8.0.3.0.1`, 
> la versión específica compatible con ESXi 8.0 U2 que evita errores de deprecación.
> Ver `BUENAS_PRACTICAS_DEPENDENCIAS.md` para más detalles.

### 3. Configurar Vault (SOLUCIÓN AL ERROR)
```bash
# Crear contraseña del vault
echo "tu_password_aqui" > .vault_pass
chmod 600 .vault_pass

# Configurar vault automáticamente
./scripts/setup_vault.sh
```

### 4. Crear VMs
```bash
# Crear todas las VMs (Router, Ubuntu, Windows)
ansible-playbook playbooks/create_vms.yml -vvv
```

### 5. Instalar SOs Manualmente
Seguir `INSTALACION_VMS.md` para instalar sistemas operativos

### 6. Configurar Router y Servicios
```bash
ansible-playbook playbooks/site.yml --tags debian,services -vvv
```

### 7. Ejecutar Proyecto Completo
```bash
ansible-playbook playbooks/site.yml -vvv
```

## 🎬 Opciones de Ejecución

### Opción 1: Ejecución Completa (Recomendada)
```bash
ansible-playbook playbooks/site.yml -vvv
```

### Opción 2: Ejecución por Fases
```bash
# Fase 1: Dispositivos de red
ansible-playbook playbooks/site.yml --tags network -vvv

# Fase 2: Crear VMs
ansible-playbook playbooks/site.yml --tags vm_creation -vvv

# Fase 3: Configurar router y servicios
ansible-playbook playbooks/site.yml --tags debian,services -vvv

# Fase 4: Firewall y seguridad
ansible-playbook playbooks/site.yml --tags firewall,security -vvv

# Fase 5: Tests y evidencias
ansible-playbook playbooks/site.yml --tags tests,evidence -vvv
```

### Opción 3: Playbooks Individuales
```bash
# Crear VMs específicas
ansible-playbook playbooks/create_vm_router.yml -vvv
ansible-playbook playbooks/create_vm_ubuntu.yml -vvv
ansible-playbook playbooks/create_vm_windows.yml -vvv

# Configurar componentes específicos
ansible-playbook playbooks/configure_ios_router.yml -vvv
ansible-playbook playbooks/configure_debian_ipv6.yml -vvv
ansible-playbook playbooks/deploy_http_service.yml -vvv

# Tests y validación
ansible-playbook playbooks/test_connectivity.yml -vvv
ansible-playbook playbooks/capture_traffic.yml -vvv
```

## 📚 Documentación

- **`README.md`** - Este archivo (visión general)
- **`GUIA_COMPLETA.md`** - Guía paso a paso completa ⭐
- **`INSTALACION_VMS.md`** - Configuración detallada para instalar VMs ⭐
- **`CONFIGURACION.md`** - Configuración técnica detallada ⭐
- **`NOTA_EJECUCION.md`** - Instrucciones críticas de ejecución ⭐

## 🔍 Verificación

### Conectividad IPv6
```bash
# Desde debian-router
ssh ansible@172.17.25.126
ping6 -c 4 2025:db8:101::10  # Ubuntu PC
ping6 -c 4 2025:db8:101::2   # Router físico

# Servicios web
curl -6 http://[2025:db8:101::1]
```

### Evidencias Generadas
```bash
# Ver evidencias
ls -la evidence/configs/
ls -la evidence/pings/
ls -la evidence/pcaps/
ls -la evidence/technical_reports/

# Abrir reportes
firefox evidence/technical_reports/index.html
```

## 🆘 Troubleshooting

### Problemas Comunes
- **Vault password**: `echo "password" > .vault_pass && chmod 600 .vault_pass`
- **Collections**: `ansible-galaxy collection install -r requirements.yml --force`
- **SSH keys**: `./scripts/copy_ssh_keys.sh`
- **Logs**: `tail -f evidence/logs/ansible.log`

### Soporte
- Consulta `GUIA_COMPLETA.md` para troubleshooting detallado
- Revisa logs en `evidence/logs/ansible.log`
- Ejecuta con `-vvvv` para debug máximo

---

**🎯 Proyecto listo para desplegar. Consulta `GUIA_COMPLETA.md` para instrucciones detalladas.**

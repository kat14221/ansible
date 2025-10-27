# Proyecto Ansible: Red IPv6 Unificada con Debian Router

## 🎯 Descripción del Proyecto

Proyecto de red IPv6 académica con **Debian Router** como gateway central de toda la topología.  
Automatización completa usando Ansible para gestionar VMs en ESXi, router IPv6, servicios y equipos físicos Cisco IOS.

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

## Requisitos

- Ansible 2.9+
- Collections: `cisco.ios`, `community.vmware`, `ansible.netcommon`
- Acceso al ESXi: 168.121.48.254
- VM de control dentro del ESXi para ejecutar los playbooks

## Configuración

### Credenciales ESXi (configuradas en inventory/hosts.yml)
- URL: https://168.121.48.254:10101/ui/#/login
- Usuario: root
- Contraseña: qwe123$

### ISOs (en datastore1)
- Debian: `datastore1:debian/debian-12.12.0-amd64-netinst.iso`
- Ubuntu: `datastore1:ubuntu/ubuntu-24.04.2-desktop-amd64.iso`
- Windows: `datastore1:W-11/Win11_24H2_Spanish_x64.iso`

## 🚀 Ejecución del Proyecto

### 📋 Pre-requisitos

1. **VM Debian Router ya creada e instalada** en ESXi con:
   - 2 adaptadores de red:
     - Adapter 1: `VM Network` (Gestión - 172.17.25.10)
     - Adapter 2: `Red Fernandez` (Proyecto IPv6)
   - Usuario `ansible` con sudo sin contraseña
   - SSH habilitado

2. **Máquina de control con Ansible** (Ubuntu/Debian):
```bash
sudo apt update
sudo apt install -y ansible git python3-pip
pip3 install pyvmomi
ansible-galaxy collection install community.vmware cisco.ios ansible.netcommon
```

### 🕹️ Paso 1: Clonar y Preparar

```bash
# Clonar repositorio
git clone <tu-repo>
cd ansible-debian

# Verificar inventario
cat inventory/hosts.yml | grep -A 20 debian_router
```

### ⭐ Paso 2: Configurar Debian Router (PRINCIPAL)

```bash
# Configurar Debian Router completo
ansible-playbook playbooks/configure_debian_ipv6.yml -vvv
```

**Esto instala y configura:**
- ✅ IPv6 Forwarding
- ✅ radvd (Router Advertisement)
- ✅ isc-dhcp-server6 (DHCPv6)
- ✅ Apache2 (HTTP)
- ✅ vsftpd (FTP)
- ✅ nftables (Firewall)
- ✅ tcpdump/tshark

### 💻 Paso 3: Crear VMs Adicionales (Opcional)

```bash
# Crear VM Ubuntu
ansible-playbook playbooks/create_vm_ubuntu.yml -vvv

# Crear VM Windows
ansible-playbook playbooks/create_vm_windows.yml -vvv
ansible-playbook playbooks/create_vm_ubuntu.yml -vvv
ansible-playbook playbooks/create_vm_windows.yml -vvv

# Configurar IOS
ansible-playbook playbooks/configure_ios_router.yml -vvv
ansible-playbook playbooks/configure_switch_svi.yml -vvv

# Configurar Debian
ansible-playbook playbooks/configure_debian_ipv6.yml -vvv
ansible-playbook playbooks/configure_dhcpv6.yml -vvv

# Desplegar servicios HTTP/FTP
ansible-playbook playbooks/deploy_http_service.yml -vvv

# Tests y capturas
ansible-playbook playbooks/test_connectivity.yml -vvv
ansible-playbook playbooks/capture_traffic.yml -vvv
ansible-playbook playbooks/deploy_all.yml --tags step1  # IOS
ansible-playbook playbooks/deploy_all.yml --tags step2  # VMs
ansible-playbook playbooks/deploy_all.yml --tags step3  # Router
ansible-playbook playbooks/deploy_all.yml --tags step4  # Servicios
# Después de crear las VMs:
# 1. Instalar el SO en cada VM manualmente
# 2. Configurar IPv6 según el inventario
# 3. Agregar adaptador físico a "Red Fernandez" en el ESXi
# 4. Verificar conectividad

# Ejecutar configuración de router y tests
ansible-playbook playbooks/deploy_all.yml --tags step3,step4
```

## Documentación

- `README.md` - Este archivo
- `NOTA_EJECUCION.md` - Instrucciones detalladas de ejecución
- `RESUMEN_CONFIGURACION.md` - Resumen de configuración
- `GUIA_USO.md` - Guía de uso rápida

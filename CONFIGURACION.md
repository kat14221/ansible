# ⚙️ Configuración del Proyecto - Red IPv6 VMWARE-101001

## 🌐 Topología de Red Unificada

### Red Principal: `2025:DB8:101::/64`
```
┌─────────────────────────────────────────────────────────────┐
│                    ESXi Host: 168.121.48.254               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              Red Fernandez (Proyecto)               │    │
│  │                2025:DB8:101::/64                     │    │
│  │                                                     │    │
│  │  ┌──────────────────┐  ┌──────────────────┐        │    │
│  │  │  Debian Router   │  │   Ubuntu PC      │        │    │
│  │  │ 2025:DB8:101::1  │  │ 2025:DB8:101::10 │        │    │
│  │  │   (Gateway)      │  │    (SLAAC)       │        │    │
│  │  └──────────────────┘  └──────────────────┘        │    │
│  │           │                                         │    │
│  │  ┌──────────────────┐                              │    │
│  │  │   Windows PC     │                              │    │
│  │  │ 2025:DB8:101::11 │                              │    │
│  │  │    (SLAAC)       │                              │    │
│  │  └──────────────────┘                              │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ Uplink físico
                              │
┌─────────────────────────────────────────────────────────────┐
│              Router Físico Cisco IOS                       │
│            2025:DB8:101::2 (GigE0/0/1)                     │
└─────────────────────────────────────────────────────────────┘
```

## 🖥️ Configuración de Hosts

### ESXi Host
- **IP**: `168.121.48.254`
- **Puerto**: `443` (HTTPS)
- **Usuario**: `root`
- **Contraseña**: `qwe123$` (en vault)
- **URL Web**: `https://168.121.48.254:10101/ui/#/login`
- **Datastore**: `datastore1`

### VM Debian Router (Gateway Principal)
- **IP Gestión**: `172.17.25.126` (VM Network)
- **IP IPv6**: `2025:DB8:101::1/64` (Red Fernandez)
- **Interfaces**:
  - `ens160`: Gestión (172.17.25.126/24)
  - `ens192`: Proyecto IPv6 (2025:DB8:101::1/64)
- **Servicios**:
  - RADVD (Router Advertisement)
  - ISC-DHCP-Server6 (DHCPv6)
  - Apache2 (HTTP)
  - vsftpd (FTP)
  - nftables (Firewall)

### VMs de Usuario
- **Ubuntu PC**: `2025:DB8:101::10/64` (SLAAC)
- **Windows PC**: `2025:DB8:101::11/64` (SLAAC)

### Router Físico Cisco IOS
- **IP**: `2025:DB8:101::2/64`
- **Hostname**: `Router-Lab`
- **Usuario**: `ansible`
- **Contraseña**: `Ansible123!` (en vault)

## 🔐 Configuración de Credenciales

### Ansible Vault
Todas las credenciales están protegidas en `group_vars/all/vault.yml`:

```yaml
# ESXi/vCenter
vault_vcenter_hostname: "168.121.48.254"
vault_vcenter_username: "root"
vault_vcenter_password: "qwe123$"
vault_vcenter_port: 443
vault_vcenter_validate_certs: false

# Cisco IOS
vault_cisco_user: "ansible"
vault_cisco_password: "Ansible123!"

# SSH Keys
vault_ansible_ssh_public_key: "ssh-rsa AAAA..."

# FTP Service
vault_ftp_user: "ftpuser"
vault_ftp_password: "ftppass123"
```

### Configurar Vault
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

## 🚀 Configuración de Servicios IPv6

### RADVD (Router Advertisement)
```bash
# /etc/radvd.conf
interface ens192 {
    AdvSendAdvert on;
    MinRtrAdvInterval 30;
    MaxRtrAdvInterval 100;
    
    prefix 2025:db8:101::/64 {
        AdvOnLink on;
        AdvAutonomous on;
        AdvRouterAddr off;
    };
};
```

### DHCPv6 (ISC-DHCP-Server6)
```bash
# /etc/dhcp/dhcpd6.conf
subnet6 2025:db8:101::/64 {
    range6 2025:db8:101::10 2025:db8:101::50;
    option dhcp6.name-servers 2001:4860:4860::8888;
    option dhcp6.domain-search "vmware-101001.local";
}
```

### Firewall (nftables)
```bash
# Reglas asimétricas implementadas
# Permitido: 2025:db8:100::/64 → 2025:db8:101::/64
# Bloqueado: 2025:db8:101::/64 → 2025:db8:100::/64 (nuevas conexiones)
```

## 📁 Estructura de Evidencias

```
evidence/
├── configs/           # Configuraciones guardadas
│   ├── debian-router_network_info.txt
│   ├── ios-router_running_config.txt
│   └── radvd.conf
├── pings/            # Resultados de conectividad
│   ├── debian-router_ping_results.txt
│   └── ubuntu_pc_ping_results.txt
├── pcaps/            # Capturas de tráfico
│   └── debian-router_capture_*.pcap
├── services/         # Estados de servicios
│   ├── debian-router_http_service.txt
│   └── debian-router_radvd_status.txt
├── reports/          # Reportes JSON
│   └── *_report.json
├── technical_reports/ # Reportes HTML
│   ├── index.html
│   └── *_technical_report.html
└── logs/             # Logs de Ansible
    └── ansible.log
```

## 🔧 Configuración de Ansible

### ansible.cfg
```ini
[defaults]
inventory = inventory/hosts.yml
roles_path = ./roles
host_key_checking = False
log_path = evidence/logs/ansible.log
vault_password_file = .vault_pass

[privilege_escalation]
become = True
become_method = sudo
become_user = root
```

### Collections Requeridas
```yaml
# requirements.yml
collections:
  - name: community.vmware
    version: ">=3.0.0"
  - name: cisco.ios
    version: ">=4.0.0"
  - name: ansible.netcommon
    version: ">=5.0.0"
  - name: ansible.posix
    version: ">=1.4.0"
  - name: ansible.utils
    version: ">=2.8.0"
```

## 🎯 Puntos de Configuración Críticos

### 1. Red IPv6 Unificada
- **Subred principal**: `2025:DB8:101::/64`
- **Gateway**: `2025:DB8:101::1` (Debian Router)
- **Rango DHCP**: `2025:DB8:101::10-50`

### 2. Interfaces de Red
- **Debian Router**: 2 interfaces (gestión + proyecto)
- **VMs Usuario**: 1 interfaz (Red Fernandez)
- **Router Físico**: Interfaz GigE0/0/1

### 3. Servicios Críticos
- **IPv6 Forwarding**: Habilitado en Debian Router
- **RADVD**: Anuncios RA cada 30-100 segundos
- **DHCPv6**: Asignación automática de direcciones
- **Firewall**: Reglas asimétricas configuradas

### 4. Seguridad
- **SSH Hardening**: Solo autenticación por llave
- **Firewalld**: Zonas internal/external configuradas
- **Fail2ban**: Protección contra ataques SSH
- **Vault**: Todas las credenciales cifradas

## ✅ Validación de Configuración

### Verificar Red IPv6
```bash
# En Debian Router
ip -6 addr show
ip -6 route show
ping6 -c 4 2025:db8:101::10  # Ubuntu PC
ping6 -c 4 2025:db8:101::2   # Router físico

# Verificar servicios
systemctl status radvd
systemctl status isc-dhcp-server6
systemctl status apache2
```

### Verificar Conectividad
```bash
# Desde Ubuntu PC
ping6 -c 4 2025:db8:101::1   # Gateway
ping6 -c 4 2025:db8:101::11  # Windows PC

# Desde Windows PC (PowerShell)
ping -6 2025:db8:101::1
```

### Verificar Servicios Web
```bash
# HTTP en IPv6
curl -6 http://[2025:db8:101::1]

# FTP en IPv6
ftp -6 2025:db8:101::1
```

Esta configuración unificada asegura consistencia en todo el proyecto y facilita el mantenimiento y troubleshooting.
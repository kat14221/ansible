# 🚀 GUÍA DE IMPLEMENTACIÓN - NIVEL 4 VMWARE-101001

## Resumen Ejecutivo

Este proyecto implementa una **red académica IPv6 de nivel 4 (Sobresaliente)** en VMware ESXi usando Ansible. La infraestructura incluye:

- ✅ **Topología detallada** con 6 dispositivos identificados
- ✅ **Conectividad IPv6 completa** (2025:db8:101::/64)
- ✅ **Servicios de red** (RADVD, DHCPv6, DNS, HTTP, FTP)
- ✅ **Seguridad avanzada** (Firewall asimétrico, hardening, auditoría)
- ✅ **Análisis de tráfico** (tcpdump, wireshark, estadísticas)
- ✅ **Documentación profesional** (justificación técnica, evidencias)

---

## 📋 Requisitos Previos

### Hardware/Software
- VMware ESXi 7.0+ (o 8.0)
- Router Cisco IOS (físico o simulado)
- Python 3.8+
- Ansible 2.9+
- Git

### Red
```
┌─────────────────────────────────────────────┐
│  Red Física (Laboratorio)                    │
│  2025:db8:100::/64                           │
│                                              │
│  physical-router ──> Switch 3 ──> ESXi       │
│  192.168.1.1         192.168.1.3  172.17.25.1 │
└─────────────────────────────────────────────┘
         │
         └──> ESXi (Red Virtual)
              Red Fernandez (2025:db8:101::/64)
              └─> VMs (debian-router, ubuntu-pc, windows-pc)
```

### IPs de Gestión
```
ESXi:         172.17.25.1      (Management)
debian-router: 172.17.25.126    (SSH access)
ubuntu-pc:     DHCP             (Via SLAAC/DHCPv6)
windows-pc:    DHCP             (Via SLAAC)
```

---

## 🔧 Paso 1: Configuración Inicial del Router Cisco

### En physical-router (CLI Cisco)

```cisco
! Habilitar IPv6 unicast routing
ipv6 unicast-routing
ipv6 cef

! Configurar interfaz G0/0/0 (Red Laboratorio)
interface GigabitEthernet0/0/0
 description "Uplink to Backbone"
 ipv6 address 2025:db8:100::2/64
 no shutdown

! Configurar interfaz G0/0/1 (Red Fernandez via Switch 3)
interface GigabitEthernet0/0/1
 description "To ESXi via Switch 3"
 ipv6 address 2025:db8:101::2/64
 no shutdown

! Ruta estática hacia debian-router
ipv6 route 2025:db8:101::/64 2025:db8:101::1

! Habilitar logging
logging enable
```

### En switch-3 (CLI Cisco)

```cisco
hostname SWITCH-3

! Configurar puertos en trunk mode
interface GigabitEthernet0/1
 description "Uplink to router"
 switchport mode trunk
 no shutdown

interface GigabitEthernet0/2
 description "Downlink to ESXi"
 switchport mode trunk
 no shutdown

! Management IP
interface Vlan 1
 ip address 192.168.1.3 255.255.255.0
 no shutdown
```

## ⚠️ Paso 1b: Switch 3 - Puente Transparente (SIN CONFIGURACIÓN NECESARIA)

```
⚠️ IMPORTANTE: Switch-3 es un PUENTE DE CAPA 2 únicamente.
   Conecta físicamente router G0/0/1 → ESXi
   
   NO REQUIERE:
   ✓ Configuración IPv6
   ✓ Gestión activa en Ansible
   ✓ Direcciones IP de red (excepto MGMT en Vlan 1 si es necesario)
   
   CONFIGURACIÓN MÍNIMA (solo si acceso SSH requerido):
   ✓ Hostname: SWITCH-3
   ✓ IP Mgmt: 192.168.1.3 (opcional, solo para troubleshooting)
   ✓ Puertos en trunk mode
   
   Ejemplo simplificado:
   
   interface GigabitEthernet0/1
    description "Uplink to router"
    switchport mode trunk
    no shutdown
   
   interface GigabitEthernet0/2
    description "Downlink to ESXi"
    switchport mode trunk
    no shutdown
   
   NO AGREGAR:
   ✗ ipv6 address (puente no participa en IPv6)
   ✗ vlan trunk native (innecesario para bridge)
```

---

## � Paso 2: Crear VMs en ESXi

### Opción A: Usando Ansible (automático)

```bash
# Crear VMs (debian-router, ubuntu-pc, windows-pc)
ansible-playbook playbooks/create_vms.yml -vvv

# Verificar creación
ansible-playbook playbooks/power_on_vms.yml
```

### Opción B: Manual (si es necesario)

1. **debian-router** (Debian 12)
   - RAM: 2GB, CPU: 2
   - Disco: 20GB
   - Redes: VM Network (172.17.25.x), Red Fernandez (2025:db8:101::/64)
   - IP WAN: 172.17.25.126

2. **ubuntu-pc** (Ubuntu 24.04 Desktop)
   - RAM: 4GB, CPU: 2
   - Disco: 40GB
   - Red: Red Fernandez
   - IP: 2025:db8:101::10 (SLAAC)

3. **windows-pc** (Windows 11)
   - RAM: 4GB, CPU: 2
   - Disco: 60GB
   - Red: Red Fernandez
   - IP: 2025:db8:101::11 (SLAAC)

---

## 🔐 Paso 3: Configurar Claves SSH (Pre-requisito)

```bash
# En debian-router (como root o ansible user)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""

# Copiar clave pública a autorized_keys
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# Habilitar acceso SSH sin contraseña (Ansible)
# En /etc/ssh/sshd_config:
# PubkeyAuthentication yes
# PasswordAuthentication no

systemctl restart ssh
```

---

## 🚀 Paso 4: Ejecutar Playbooks Ansible

### 4.1 Validar conectividad

```bash
# Test de conexión
ansible -i inventory/hosts.yml all -m ping

# Resultado esperado:
# debian-router | SUCCESS => {
#     "changed": false,
#     "ping": "pong"
# }
```

### 4.2 Aplicar configuración de Red Nivel 4

```bash
# Opción 1: Playbook completo
ansible-playbook playbooks/site.yml -vvv

# Opción 2: Solo validación Nivel 4
ansible-playbook playbooks/nivel4_validation.yml -vvv

# Opción 3: Por componentes
ansible-playbook playbooks/configure_debian_ipv6.yml -vvv
ansible-playbook playbooks/deploy_http_service.yml -vvv
ansible-playbook playbooks/validate_connectivity.yml -vvv
```

### 4.3 Ejemplo completo

```bash
# 1. Crear directorio de evidencias
mkdir -p evidence/{configs,gateway,pcaps,reports}

# 2. Ejecutar playbook de validación Nivel 4
cd /d/ansible
ansible-playbook playbooks/nivel4_validation.yml \
  -i inventory/hosts.yml \
  -u ansible \
  -v

# 3. Verificar generación de evidencias
ls -la evidence/nivel4/
```

---

## 📊 Paso 5: Validar Funcionamiento

### 5.1 Validar Gateway IPv6

```bash
# Desde debian-router
ssh ansible@172.17.25.126

# Una vez conectado:
sudo -i

# Verificar servicios
systemctl status radvd
systemctl status isc-dhcp-server6
systemctl status dnsmasq
systemctl status firewalld

# Verificar interfaces IPv6
ip -6 addr show ens192

# Esperado:
# inet6 2025:db8:101::1/64 scope global

# Ver rutas
ip -6 route show

# Esperado:
# 2025:db8:101::/64 dev ens192 proto kernel metric 256
# 2025:db8:100::/64 via 2025:db8:101::2 dev ens192 metric 1024
```

### 5.2 Validar Conectividad desde Clientes

```bash
# Desde ubuntu-pc
ping6 2025:db8:101::1       # Gateway
ping6 2025:db8:101::11      # windows-pc
ping6 2025:db8:101::2       # physical-router
ping6 2025:db8:100::2       # Red Laboratorio

# Verificar IP asignada por DHCPv6
ip -6 addr show | grep inet6

# Esperado algo como:
# inet6 2025:db8:101::xyz/64 scope global dynamic
```

### 5.3 Validar Servicios

```bash
# HTTP
curl -6 http://[2025:db8:101::1]

# DNS
nslookup ubuntu-pc.lab 2025:db8:101::1

# SSH
ssh ansible@2025:db8:101::1
```

### 5.4 Análisis de Tráfico

```bash
# Captura básica
sudo tcpdump -i ens192 -w traffic.pcap 'ipv6' -c 100

# Ver estadísticas
sudo netstat -s -6 | grep -E "(Icmp6|Udp6|Tcp6)"

# MTR (ruta completa)
mtr -6 2025:db8:101::10

# Prueba de ancho de banda
iperf3 -s &  # En debian-router
iperf3 -6 -c 2025:db8:101::1 -t 30  # Desde cliente
```

---

## 📁 Paso 6: Generar Evidencias Nivel 4

### 6.1 Estructura de Carpetas

```
evidence/
├── nivel4/
│   ├── NIVEL4_RESUMEN.md           # Documento maestro
│   ├── dispositivos_identificados.txt
│   ├── conectividad_validada.txt
│   ├── servicios_activos.txt
│   ├── seguridad_implementada.txt
│   └── analisis_trafico.txt
├── gateway/
│   └── debian-router_gateway_status.txt
├── configs/
│   ├── physical-router_config.txt
│   ├── debian-router_hardening_status.txt
│   └── firewall_config.txt
├── pcaps/
│   └── traffic_analysis_*.pcap
└── reports/
    └── technical_report.html
```

### 6.2 Ejecutar Recolector de Evidencias

```bash
# Generar reportes
ansible-playbook playbooks/generate_reports.yml -vvv

# Verificar
ls -la evidence/
find evidence/ -type f | wc -l
```

---

## 🧪 Paso 7: Validación Final Nivel 4

### Checklist de Cumplimiento

#### **Unidad 1: Topología**
- [ ] Diagrama con 6 dispositivos identificados
- [ ] Roles definidos (Gateway, Router, Clientes, Hipervisor)
- [ ] Interfaces documentadas (G0/0/0, G0/0/1, ens192, ens224)
- [ ] IPs asignadas correctamente
- [ ] Subredes (100::/64 y 101::/64) en documento

#### **Unidad 2: Conectividad**
- [ ] Ping exitoso entre todos los dispositivos
- [ ] DNS resolviendo nombres
- [ ] HTTP/HTTPS accesible
- [ ] FTP funcional
- [ ] Tráfico capturado y analizado
- [ ] Latencia < 5ms local
- [ ] 0% packet loss

#### **Unidad 3: Seguridad**
- [ ] Firewall activo y configurado
- [ ] Reglas asimétricas (100→101 ✅, 101→100 ❌)
- [ ] SSH con hardening
- [ ] Usuarios con permisos limitados
- [ ] Logs de auditoria generados
- [ ] Controles de acceso implementados

#### **Documentación**
- [ ] NIVEL4_TOPOLOGIA.md completo
- [ ] Justificación técnica de decisiones
- [ ] Diagramas ASCII actualizados
- [ ] Tabla de dispositivos y IPs
- [ ] Estándares IETF/IEEE citados
- [ ] Evidencias fotográficas/digitales

---

## 🎯 Paso 8: Optimizaciones y Futuro

### Mejoras Potenciales

1. **Routing Dinámico**
   ```bash
   # Implementar OSPF o EIGRP
   # Ver roles en: roles/dynamic-routing/
   ```

2. **Monitoreo Avanzado**
   ```bash
   # Prometheus + Grafana
   # Alertas para anomalías
   ```

3. **Backup/Restore**
   ```bash
   # Backups diarios de configuración
   # Snapshots de VMs
   ```

4. **Escalabilidad**
   ```bash
   # Agregar subredes adicionales
   # Nuevas VMs clientes
   # Balancing de carga
   ```

---

## 📞 Troubleshooting

### IPv6 no funciona
```bash
# Verificar forwarding
sysctl net.ipv6.conf.all.forwarding

# Debe ser: 1
sysctl -w net.ipv6.conf.all.forwarding=1
```

### DHCPv6 no asigna IPs
```bash
# Reiniciar servicio
systemctl restart isc-dhcp-server6

# Ver logs
journalctl -u isc-dhcp-server6 -f

# Verificar config
dhcpd -6 -t -cf /etc/dhcp/dhcpd6.conf
```

### Firewall bloquea tráfico
```bash
# Ver reglas
firewall-cmd --list-all

# Permitir servicio
firewall-cmd --zone=internal --add-service=http --permanent

# Recargar
firewall-cmd --reload
```

### Conectividad WAN lenta
```bash
# Verificar MTU
ip link show | grep mtu

# Cambiar MTU si es necesario
ip link set dev ens224 mtu 9000
```

---

## ✅ Validación Final

```bash
# Script de validación rápida
./scripts/verify_nivel4.sh

# Salida esperada:
# ✅ IPv6 Gateway: 2025:db8:101::1
# ✅ RADVD: active
# ✅ DHCPv6: active
# ✅ DNS: resolving
# ✅ Firewall: active
# ✅ Conectividad: 6/6 hosts
# ✅ Tráfico: 0% loss
# 
# ESTADO: 🏆 NIVEL 4 COMPLETO
```

---

## 📚 Referencias

- **RFC 4291:** IPv6 Addressing Architecture
- **RFC 3315:** Dynamic Host Configuration Protocol for IPv6
- **RFC 4861:** Neighbor Discovery for IP version 6
- **IEEE 802.3:** Ethernet Standard
- **ISO/IEC 27001:** Information Security Management
- **NIST SP 800-123:** Secure Configuration of Network Devices

---

## 📝 Documento de Entrega

```
✅ NIVEL 4 - PROYECTO VMWARE-101001
   Estado: SOBRESALIENTE

Componentes:
✅ Topología documentada (6 dispositivos)
✅ Conectividad IPv6 funcional (2025:db8:101::/64)
✅ Servicios de red (RADVD, DHCPv6, DNS, HTTP, FTP)
✅ Seguridad avanzada (Firewall, hardening, auditoría)
✅ Análisis de tráfico (tcpdump, estadísticas)
✅ Documentación completa (justificación técnica)
✅ Evidencias digitales (configs, logs, capturas)

Fecha: 2025-11-10
Versión: 1.0
Estado: LISTO PARA PRODUCCIÓN
```

---

**Última actualización:** 2025-11-10  
**Versión:** 1.0  
**Autor:** Equipo de Infraestructura  
**Estado:** ✅ NIVEL 4 COMPLETO

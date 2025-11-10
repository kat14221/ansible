# 📡 TOPOLOGÍA EXTENDIDA - Network Monitor + GNS3 + Access Point

Documento que describe la extensión de la topología actual con nuevos componentes de simulación y acceso inalámbrico.

---

## 🏗️ Arquitectura Extendida

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                     TOPOLOGÍA NIVEL 4 EXTENDIDA                              ║
║                     Red VMWARE-101001 + Simulación + WiFi                    ║
╚══════════════════════════════════════════════════════════════════════════════╝

┌─────────────────────────────────────────────────────────────────────────────┐
│  CAPA FÍSICA - Laboratorio Real                                              │
│  ═════════════════════════════════════════════════════════════════════════   │
│                                                                               │
│  ┌─────────────────┐         ┌──────────────┐                              │
│  │ physical-router │◄────────│  Switch-3    │                              │
│  │ (G0/0/0, G0/0/1)│         │ (Layer 2)    │                              │
│  │ 100::2, 101::2  │         │ (Transparent)│                              │
│  └────────┬────────┘         └──────┬───────┘                              │
│           │ (IPv6)                  │                                       │
│   ┌───────┴────────────┬────────────┴────┐                                 │
│   │                    │                 │                                 │
│   ▼                    ▼                 ▼                                 │
│ ┌─────────────┐  ┌──────────────┐  ┌──────────────┐                       │
│ │  ESXi Host  │  │  GNS3 Laptop │  │ Access Point │                       │
│ │172.17.25.1  │  │ (Simulador)  │  │  (802.11ac)  │                       │
│ │ VM Network  │  │              │  │              │                       │
│ └────────┬────┘  └──────┬───────┘  └──────┬───────┘                       │
│          │               │                  │                               │
│   ┌──────┴──────────┐    │            ┌─────┴──────┐                      │
│   │ Red Fernandez   │    │            │  WiFi Zona │                      │
│   │ (2025:db8:101::│    │            │  (5GHz)    │                      │
│   │      /64)       │    │            │            │                      │
│   └──────┬──────────┘    │            └─────┬──────┘                      │
│          │               │                  │                               │
└──────────┼───────────────┼──────────────────┼───────────────────────────┘
           │ IPv6          │ Simulación       │ WiFi
           │ (Real)        │ (GNS3)           │ (Inálambrico)
┌──────────┼───────────────┼──────────────────┼───────────────────────────┐
│ CAPA VIRTUAL - ESXi                                                      │
│ ═══════════════════════════════════════════════════════════════════════  │
│          │                                  │                             │
│   ┌──────▼──────────────────────────┐      │                            │
│   │  Red Fernandez Virtual (VSW)    │      │                            │
│   │  2025:db8:101::/64              │      │                            │
│   │  (Switch Virtual ESXi)          │      │                            │
│   └──────┬──────────────────────────┘      │                            │
│          │                                  │                            │
│   ┌──────┴──────┬──────────┬──────────┐    │                            │
│   │             │          │          │    │                            │
│   ▼             ▼          ▼          ▼    │                            │
│ ┌──────────┐ ┌────────┐ ┌────────┐ ┌──────┴──────────┐                 │
│ │debian-   │ │ubuntu- │ │windows-│ │                │                 │
│ │router    │ │  pc    │ │  pc    │ │   Network      │                 │
│ │101::1    │ │101::10 │ │101::11 │ │   Monitor      │                 │
│ │Gateway   │ │(client)│ │(client)│ │   Dashboard    │                 │
│ │NAT+Svcs  │ │        │ │        │ │   (Puerto 5000)│                 │
│ └──────────┘ └────────┘ └────────┘ └────────────────┘                 │
│                                              │                            │
└──────────────────────────────────────────────┼────────────────────────┘
                                               │
                                        ┌──────▼────────────┐
                                        │ 📊 Network Monitor│
                                        │ ✅ Visualización  │
                                        │ ✅ SSH Integrado  │
                                        │ ✅ Estadísticas   │
                                        └───────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│  SIMULACIÓN GNS3 - En Laptop Externa                                        │
│  ═════════════════════════════════════════════════════════════════════════   │
│                                                                               │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │  GNS3 Server (en Laptop Física)                                      │   │
│  │                                                                       │   │
│  │  ┌─────────────────────────────────────────────────────────────┐    │   │
│  │  │  Cloud (NIC Física - Conexión a Red Real)                  │    │   │
│  │  │  (Representa la laptop física)                             │    │   │
│  │  └──────────────────────┬──────────────────────────────────────┘    │   │
│  │                         │ (Cable físico hacia Switch)               │   │
│  │  ┌──────────────────────▼──────────────────────────────────────┐    │   │
│  │  │  Switch Virtual (en GNS3)                                  │    │   │
│  │  └──────────────────────┬──────────────────────────────────────┘    │   │
│  │                         │                                            │   │
│  │         ┌───────────────┼───────────────┬──────────────┐            │   │
│  │         │               │               │              │            │   │
│  │         ▼               ▼               ▼              ▼            │   │
│  │    ┌────────────┐  ┌────────────┐ ┌──────────┐ ┌──────────┐       │   │
│  │    │  Ubuntu    │  │  macOS     │ │ Windows  │ │ Ubuntu   │       │   │
│  │    │ (VBox)     │  │  (VBox)    │ │ 11(VBox) │ │ Hannah   │       │   │
│  │    └────────────┘  └────────────┘ └──────────┘ └──────────┘       │   │
│  │                                                                      │   │
│  │  Máquinas Virtuales en Oracle VirtualBox                           │   │
│  │  (Simuladas dentro del GNS3)                                       │   │
│  │                                                                      │   │
│  └──────────────────────────────────────────────────────────────────┘   │   │
│                                                                          │   │
│  📝 Propósito: Simular topología de red adicional                      │   │
│     - Aprender arquitecturas complejas                                  │   │
│     - Simular fallas y recuperación                                     │   │
│     - Labtest sin hardware adicional                                    │   │
│                                                                          │   │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│  ACCESS POINT + CLIENTES INALÁMBRICOS                                       │
│  ═════════════════════════════════════════════════════════════════════════   │
│                                                                               │
│  ┌──────────────────────────────────┐                                       │
│  │  Cisco Access Point (802.11ac)   │                                       │
│  │  IP: 2025:db8:101::50            │                                       │
│  │  SSID: VMWARE-101001-5G          │                                       │
│  │  Frecuencia: 5 GHz               │                                       │
│  │  Seguridad: WPA3                 │                                       │
│  └───────────────┬────────────────────┘                                     │
│                  │                                                           │
│         ┌────────┴────────┐                                                 │
│         │                 │                                                 │
│         ▼                 ▼                                                 │
│   ┌──────────────┐  ┌──────────────┐                                       │
│   │   Laptop     │  │   Celular    │                                       │
│   │  (Conectada) │  │  (Conectado) │                                       │
│   │ 2025:db8:101:│  │ 2025:db8:101:│                                       │
│   │   :60/64     │  │   :61/64     │                                       │
│   └──────────────┘  └──────────────┘                                       │
│                                                                              │
│   ✅ Acceso completo a servicios                                            │
│   ✅ Ping a otros dispositivos                                              │
│   ✅ Acceso SSH a debian-router                                             │
│   ✅ Visualización Network Monitor                                          │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 📊 Tabla de Dispositivos - Topología Extendida

| # | Dispositivo | Tipo | IPv6 | Función | Ubicación | Estado |
|---|---|---|---|---|---|---|
| 1 | physical-router | Router | 100::2, 101::2 | Gateway Lab | Físico | ✅ |
| 2 | switch-3 | Switch L2 | N/A | Puente | Físico | ✅ |
| 3 | esxi-01 | Hipervisor | N/A | Virtualización | Físico | ✅ |
| 4 | debian-router | VM | 101::1 | Gateway IPv6 + NAT | ESXi | ✅ |
| 5 | ubuntu-pc | VM | 101::10 | Cliente | ESXi | ✅ |
| 6 | windows-pc | VM | 101::11 | Cliente | ESXi | ✅ |
| 7 | **network-monitor** | **Aplicación** | **:5000** | **Dashboard Web** | **ESXi** | **🆕** |
| 8 | **gns3-laptop** | Laptop Ext | Eth0 (sim) | Simulación | Externa | 🆕 |
| 9 | **ubuntu-gns3** | VM (GNS3) | Var | Simulada | GNS3 | 🆕 |
| 10 | **macos-gns3** | VM (GNS3) | Var | Simulada | GNS3 | 🆕 |
| 11 | **windows-gns3** | VM (GNS3) | Var | Simulada | GNS3 | 🆕 |
| 12 | **hannah-gns3** | VM (GNS3) | Var | Simulada | GNS3 | 🆕 |
| 13 | **access-point** | AP WiFi | 101::50 | WiFi Gateway | Físico | 🆕 |
| 14 | **laptop-wifi** | Laptop | 101::60 | Cliente WiFi | Remota | 🆕 |
| 15 | **celular-wifi** | Smartphone | 101::61 | Cliente WiFi | Remota | 🆕 |

---

## 🖥️ Interfaces de Red - Desglose Completo

### Red Fernandez IPv6 (2025:db8:101::/64)

```
Dirección Base: 2025:db8:101::/64
Máscara: /64
Prefijo: 64 bits
Rango Utilizable: 2025:db8:101::1 - 2025:db8:101::ffff:ffff:ffff:ffff

Asignaciones Fijas:
├─ ::1         → debian-router (gateway)
├─ ::2         → physical-router
├─ ::10        → ubuntu-pc
├─ ::11        → windows-pc
├─ ::50        → access-point
├─ ::60        → laptop-wifi
├─ ::61        → celular-wifi
├─ ::100-::ff  → DHCP Pool (clientes dinámicos)
└─ ::fffe      → Reservado

GNS3 Simulación (direcciones internas):
├─ No tiene IPs en red real
├─ Red aislada en GNS3
└─ Conecta a red real vía Cloud NIC
```

---

## 🔄 Flujo de Tráfico

### Dentro de Red Fernandez (todo IPv6)

```
ubuntu-pc (101::10)
         ▼
    IPv6 Routing
         ▼
debian-router (101::1)
         ▼
    forwarding IPv6
         ▼
┌────────┴────────┐
│                 │
▼                 ▼
windows-pc    AP WiFi
(101::11)     (101::50)
         │
    [WiFi 802.11ac]
         │
    ┌────┴──────┐
    │            │
    ▼            ▼
Laptop-WiFi  Celular-WiFi
(101::60)    (101::61)
```

### Desde Red Fernandez a Red Laboratorio

```
2025:db8:101::/64 (Fernandez)
       ▼
debian-router (101::1)
       ▼
physical-router (101::2)
       ▼
2025:db8:100::/64 (Laboratorio)
```

### Acceso a Network Monitor

```
Desde cualquier dispositivo:
- Navegador: http://debian-router:5000
- O: http://[2025:db8:101::1]:5000
- O: ssh -L 5000:localhost:5000 ansible@2025:db8:101::1

Dashboard:
├─ Escanea automáticamente
├─ Detecta todos los dispositivos
├─ Permite SSH desde interfaz
└─ Muestra estadísticas en tiempo real
```

---

## 🚀 Pasos para Expandir Topología

### 1. Instalar Network Monitor (YA HECHO)

```bash
ansible-playbook playbooks/deploy_network_monitor.yml \
  -i inventory/hosts.yml
```

**Resultado:**
- ✅ Dashboard web en puerto 5000
- ✅ Detección automática de dispositivos
- ✅ SSH integrado
- ✅ Visualización en tiempo real

### 2. Configurar GNS3 en Laptop Externa

**Pasos:**
1. Instalar GNS3 en laptop física
2. Crear proyecto GNS3
3. Agregar Cloud node (conecta a NIC física)
4. Crear Switch virtual
5. Agregar 4 VMs Oracle VirtualBox:
   - Ubuntu Desktop
   - macOS
   - Windows 11
   - Ubuntu (Hannah Montana)
6. Conectar Switch a Cloud
7. Configurar Cloud para usar NIC física hacia red real

**Configuración Cloud GNS3:**
```
Cloud Node:
├─ Adapter: Ethernet física (la que tiene cable al switch)
├─ Modo: Bridge
└─ Conecta la laptop a red Fernandez
```

### 3. Configurar Access Point

**En Access Point Cisco:**

```cisco
hostname access-point

! Interfaz WiFi
interface WiFi0
 description "Red Fernandez"
 ipv6 address 2025:db8:101::50/64
 ipv6 enable
 no shutdown

! SSID
ssid VMWARE-101001-5G
 authentication open
 channel-list 149-165
 band 5G
 power 30
 no shutdown

! DHCP IPv6
dhcp-server enable
ipv6 dhcp pool fernandez
 address prefix 2025:db8:101::200/64
 dns 2025:db8:101::1

! Firewall
firewall enable
access-list ingress-wifi
 permit ipv6 any any
```

### 4. Conectar Clientes WiFi

**Dispositivos inalámbricos:**
- Laptop: SSID "VMWARE-101001-5G", contraseña [configurar]
- Celular: Mismo SSID y contraseña

**Verificación:**
```bash
# Desde laptop WiFi:
ping6 2025:db8:101::1    # ✅ Debe responder
ping6 2025:db8:101::10   # ✅ Debe responder (ubuntu-pc)
ssh -6 ansible@2025:db8:101::1  # ✅ SSH debe funcionar
```

---

## 📊 Ventajas de la Topología Extendida

| Aspecto | Beneficio |
|--------|-----------|
| **Network Monitor** | Visualización profesional en tiempo real |
| **GNS3 Simulación** | Aprender sin requerir más hardware |
| **WiFi Access Point** | Pruebas de movilidad y seamless roaming |
| **Múltiples Clientes** | Simular carga y tráfico concentrado |
| **Dashboard Web** | Gestión centralizada y fácil |

---

## 🔐 Seguridad en Topología Extendida

```
┌─────────────────────────────────────────────┐
│  FIREWALL debian-router                     │
│  ═════════════════════════════════════════  │
│                                             │
│  Zona Internal (LAN):                       │
│  ├─ ALLOW: 2025:db8:101::/64 IPv6          │
│  ├─ ALLOW: SSH (22), HTTP (80), HTTPS(443) │
│  └─ ALLOW: DNS (53), DHCPv6 (546/547)      │
│                                             │
│  Zona External (WAN - hacia 100::):        │
│  ├─ ALLOW: established connections         │
│  └─ DENY: New connections (asimétrico)     │
│                                             │
│  Access Point:                              │
│  ├─ WPA3 habilitado                        │
│  ├─ Only IPv6 (no IPv4)                    │
│  └─ RATE-LIMIT: 100 Mbps por cliente       │
│                                             │
│  GNS3 Simulación:                           │
│  ├─ Red aislada (sin acceso directo ESXi)  │
│  └─ Solo conecta vía Cloud (controlado)    │
│                                             │
└─────────────────────────────────────────────┘
```

---

## 📈 Monitoreo del Network Monitor

### API Endpoints Disponibles

```bash
# Ver todos los dispositivos
curl http://debian-router:5000/api/devices

# Hacer escaneo manual
curl http://debian-router:5000/api/scan

# Ver detalles de un dispositivo
curl http://debian-router:5000/api/device/2025:db8:101::10

# Ping a dispositivo
curl http://debian-router:5000/api/ping/2025:db8:101::50

# Ver estadísticas
curl http://debian-router:5000/api/stats

# Exportar JSON
curl http://debian-router:5000/api/export?format=json

# Exportar CSV
curl http://debian-router:5000/api/export?format=csv
```

---

## ✅ Checklist de Implementación

```
✅ Network Monitor Dashboard
   ├─ Flask backend
   ├─ Bootstrap frontend
   ├─ API REST completa
   ├─ Detección IPv6
   └─ SSH integrado

⏳ GNS3 Simulación (Próximo)
   ├─ Instalar GNS3
   ├─ Crear 4 VMs
   ├─ Configurar Cloud Node
   └─ Conectar a red real

⏳ Access Point WiFi (Próximo)
   ├─ Configurar SSID
   ├─ Habilitar WPA3
   ├─ Asignar IPv6 estática
   └─ Configurar DHCP

⏳ Clientes WiFi (Próximo)
   ├─ Conectar laptop
   ├─ Conectar celular
   ├─ Verificar IPv6
   └─ Pruebas de conectividad
```

---

## 📚 Documentación Relacionada

- [Network Monitor README](roles/network-monitor/README.md)
- [NIVEL4_TOPOLOGIA.md](docs/NIVEL4_TOPOLOGIA.md)
- [IMPLEMENTACION_NIVEL4.md](docs/IMPLEMENTACION_NIVEL4.md)
- [CORRECCION_ARQUITECTURA.md](CORRECCION_ARQUITECTURA.md)

---

**Estado:** 📝 En Progreso  
**Network Monitor:** ✅ Completado  
**GNS3 + WiFi:** ⏳ Próximamente  
**Versión:** 1.1 Extended  
**Fecha:** 2025-11-10

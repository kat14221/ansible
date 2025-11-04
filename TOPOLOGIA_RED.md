# 🌐 Topología de Red - VMWARE-101001

## Diagrama de Red

```
                    Internet/Backbone
                           │
                           │
                    ┌──────▼──────┐
                    │  Router      │
                    │  Físico      │ ← physical-router
                    │              │
                    └─┬──────────┬─┘
                      │          │
         G0/0/0 ─────┘          └───── G0/0/1
      2025:db8:100::2              2025:db8:101::2
             │                            │
             │                            │
      ┌──────▼──────┐             ┌──────▼──────┐
      │  Switch 1   │             │  Switch 3   │
      │  (Físico)   │             │  (Físico)   │
      └─────────────┘             └──────┬──────┘
             │                            │
      Red Laboratorio                     │
      2025:db8:100::/64            ┌──────▼──────┐
                                   │    ESXi     │
                                   │ Hypervisor  │
                                   └──────┬──────┘
                                          │
                                          │
                              ┌───────────▼──────────────┐
                              │   Red Fernandez          │
                              │   (Switch Virtual)       │
                              │   2025:db8:101::/64      │
                              └─┬────────────┬──────────┬┘
                                │            │          │
                    ┌───────────▼──┐   ┌────▼────┐  ┌─▼──────┐
                    │ debian-router│   │ubuntu-pc│  │windows │
                    │     (VM)     │   │  (VM)   │  │ -pc(VM)│
                    │ 2025:db8:    │   │2025:db8:│  │2025:db8│
                    │  101::1      │   │ 101::10 │  │ 101::11│
                    └──────────────┘   └─────────┘  └────────┘
                    Router/Gateway      Cliente       Cliente
                    DHCP/RADVD         Linux         Windows
```

## 📋 Inventario de Dispositivos

### **🔧 Router Físico (physical-router)**
- **Tipo:** Cisco IOS Router
- **Hostname:** PHYSICAL-ROUTER
- **IP Gestión:** `192.168.1.1` (⚠️ ajustar según tu configuración real)
- **Interfaces:**
  - **G0/0/0:** `2025:db8:100::2/64` → Switch 1 (Red Laboratorio/Backbone)
  - **G0/0/1:** `2025:db8:101::2/64` → Switch 3 → ESXi
- **Rutas Estáticas:**
  - `2025:db8:101::/64` via `2025:db8:101::1` (debian-router)
- **Acceso:** `network_cli` (Cisco IOS)

---

### **🔀 Switch 3 (switch-3)**
- **Tipo:** Cisco IOS Switch (físico)
- **Hostname:** SWITCH-3
- **IP Gestión:** `192.168.1.3` (⚠️ ajustar según tu configuración real)
- **Función:** Puente entre physical-router G0/0/1 y ESXi
- **Puertos:**
  - **G0/1:** Uplink a physical-router G0/0/1
  - **G0/2:** Downlink a ESXi
- **Acceso:** `network_cli` (Cisco IOS)

---

### **🖥️ ESXi Hypervisor**
- **Tipo:** VMware ESXi
- **IP Gestión:** `172.17.25.1`
- **vCenter User:** `root`
- **Datacenter:** `ha-datacenter`
- **Datastore:** `datastore1`
- **Switch Virtual:** Red Fernandez (conectado a Switch 3)

---

### **🐧 debian-router (VM)**
- **Tipo:** Debian 12 (VM en ESXi)
- **Hostname:** debian-router
- **IP Gestión:** `172.17.25.126` (interfaz WAN)
- **IP LAN IPv6:** `2025:db8:101::1/64` (interfaz ens192)
- **Función:**
  - Router IPv6 para Red Fernandez
  - Servidor RADVD (Router Advertisement)
  - Servidor DHCPv6
  - Firewall (firewalld)
  - Servicios HTTP/FTP
- **Interfaces:**
  - **ens224 (WAN):** `172.17.25.126` - Gestión
  - **ens192 (LAN):** `2025:db8:101::1/64` - Red Fernandez
- **Acceso:** SSH (ansible@172.17.25.126)

---

### **🖥️ ubuntu-pc (VM)**
- **Tipo:** Ubuntu 24.04 Desktop (VM en ESXi)
- **Hostname:** ubuntu-pc
- **IPv6:** `2025:db8:101::10/64` (SLAAC desde debian-router)
- **Gateway:** `2025:db8:101::1` (debian-router)
- **Red:** Red Fernandez
- **Acceso:** SSH (ansible@2025:db8:101::10)

---

### **🪟 windows-pc (VM)**
- **Tipo:** Windows 11 (VM en ESXi)
- **Hostname:** windows-pc
- **IPv6:** `2025:db8:101::11/64` (SLAAC desde debian-router)
- **Gateway:** `2025:db8:101::1` (debian-router)
- **Red:** Red Fernandez
- **Acceso:** WinRM (Administrator@2025:db8:101::11)

---

## 🌐 Subredes IPv6

### **2025:db8:100::/64 - Red Laboratorio/Backbone**
- **Gateway:** physical-router G0/0/0 (`2025:db8:100::2`)
- **Propósito:** Red externa, laboratorio, backbone
- **Conectividad:** Física (Switch 1)

### **2025:db8:101::/64 - Red Fernandez (Principal)**
- **Gateway:** debian-router (`2025:db8:101::1`)
- **Router Físico:** physical-router G0/0/1 (`2025:db8:101::2`)
- **DHCP/RADVD:** Provisto por debian-router
- **Rango DHCP:** `2025:db8:101::100` - `2025:db8:101::200`
- **Hosts:**
  - `::1` - debian-router (gateway)
  - `::2` - physical-router G0/0/1
  - `::10` - ubuntu-pc
  - `::11` - windows-pc
- **Conectividad:** Virtual (Red Fernandez en ESXi)

---

## 🔥 Reglas de Firewall (firewalld en debian-router)

### **Reglas Asimétricas:**
- ✅ **Permitido:** Tráfico desde `2025:db8:100::/64` → `2025:db8:101::/64`
- ❌ **Bloqueado:** Tráfico desde `2025:db8:101::/64` → `2025:db8:100::/64` (nuevas conexiones)
- ✅ **Permitido:** Respuestas a conexiones establecidas (stateful)

### **Zonas:**
- **internal:** Red Fernandez (2025:db8:101::/64)
- **external:** Red Laboratorio (2025:db8:100::/64)

---

## 🔀 Flujo de Tráfico

### **Desde Red Fernandez hacia Internet:**
```
ubuntu-pc (101::10)
    ↓
debian-router (101::1) [NAT/Firewall]
    ↓
physical-router (101::2)
    ↓
Internet/Backbone
```

### **Desde Red Laboratorio hacia Red Fernandez:**
```
Laboratorio (100::/64)
    ↓
physical-router G0/0/0 (100::2)
    ↓
physical-router G0/0/1 (101::2)
    ↓
Switch 3
    ↓
ESXi → Red Fernandez
    ↓
debian-router (101::1) [Firewall permite]
    ↓
ubuntu-pc / windows-pc
```

### **Desde Red Fernandez hacia Red Laboratorio (BLOQUEADO):**
```
ubuntu-pc (101::10)
    ↓
debian-router (101::1) [Firewall BLOQUEA nuevas conexiones]
    ✗ BLOQUEADO
```

---

## 📊 Tabla de IPs Resumida

| Host | IPv6 (Red Fernandez) | IPv6 (Laboratorio) | IPv4 Gestión |
|------|---------------------|-------------------|--------------|
| **physical-router** | `2025:db8:101::2` | `2025:db8:100::2` | `192.168.1.1` |
| **switch-3** | - | - | `192.168.1.3` |
| **ESXi** | - | - | `172.17.25.1` |
| **debian-router** | `2025:db8:101::1` | - | `172.17.25.126` |
| **ubuntu-pc** | `2025:db8:101::10` | - | - |
| **windows-pc** | `2025:db8:101::11` | - | - |

---

## ⚙️ Configuración de Routing

### **En physical-router (Cisco IOS):**
```cisco
ipv6 unicast-routing

interface GigabitEthernet0/0/0
 description Uplink to Backbone/Laboratorio
 ipv6 address 2025:db8:100::2/64
 no shutdown

interface GigabitEthernet0/0/1
 description Conexion a Switch 3 -> ESXi -> Red Fernandez
 ipv6 address 2025:db8:101::2/64
 no shutdown

ipv6 route 2025:db8:101::/64 2025:db8:101::1
```

### **En debian-router (Linux):**
```bash
# Habilitar forwarding IPv6
sysctl -w net.ipv6.conf.all.forwarding=1

# Interfaz LAN (ens192)
ip -6 addr add 2025:db8:101::1/64 dev ens192

# Ruta hacia laboratorio
ip -6 route add 2025:db8:100::/64 via 2025:db8:101::2
```

---

## 🔧 IPs de Gestión a Configurar

⚠️ **IMPORTANTE:** Actualizar en `inventory/hosts.yml`:

1. **physical-router:**
   - Línea 121: Cambiar `192.168.1.1` por la IP de gestión real

2. **switch-3:**
   - Línea 142: Cambiar `192.168.1.3` por la IP de gestión real

---

## ✅ Validación de Conectividad

### **Desde debian-router:**
```bash
# Ping a physical-router
ping6 -c 4 2025:db8:101::2

# Ping a red laboratorio (vía physical-router)
ping6 -c 4 2025:db8:100::2

# Ver tabla de rutas
ip -6 route show
```

### **Desde ubuntu-pc:**
```bash
# Ping a gateway (debian-router)
ping6 -c 4 2025:db8:101::1

# Ping a physical-router
ping6 -c 4 2025:db8:101::2

# Ping a windows-pc
ping6 -c 4 2025:db8:101::11
```

### **Desde physical-router:**
```cisco
# Ping a debian-router
ping ipv6 2025:db8:101::1

# Verificar rutas
show ipv6 route
```

---

**Última actualización:** 2025-11-04  
**Proyecto:** VMWARE-101001 - Red Académica IPv6

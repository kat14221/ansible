# Contexto del Proyecto - Red Académica IPv6 VMWARE-101001

## Contexto Académico

Este proyecto forma parte de la asignatura de **Redes de Datos** dentro del ámbito académico de **Ingeniería de Telecomunicaciones**. El objetivo principal es demostrar la comprensión práctica de:

- **Protocolos IPv6** y su implementación en escenarios reales
- **Automatización de infraestructura** con herramientas de gestión de configuración (IaC - Infrastructure as Code)
- **Operación de redes** mediante técnicas modernas de DevOps/NetDevOps
- **Análisis de tráfico** y diagnóstico de problemas de red

### Requisitos del Profesor

Según las especificaciones del curso, el proyecto debe demostrar:

1. **Configuración básica en equipos IOS**: hostname, banners, credenciales, `ipv6 unicast-routing`, SVIs de gestión y puertos de acceso/troncal
2. **Asignación automática de direccionamiento**: uso de SLAAC/DHCPv6 para entrega automática de direcciones IPv6
3. **Habilitación de acceso por interfaces físicas/virtuales**: configuración correcta de interfaces de red
4. **Funcionalidad básica**: verificable mediante pings entre dispositivos
5. **Análisis de tráfico**: captura con Wireshark mediante SPAN en switch de acceso
6. **Servicios de aplicación**: despliegue de servicios de capa 7 (HTTP/DNS) para validar funcionalidad completa

## Contexto de Red Académica

### Infraestructura Física

**Entorno**: Sala de laboratorio **VMWARE-101001** dentro de un datacenter académico.

**Hardware**:
- **Estación de trabajo con ESXi Host Client**: Workstation con virtualización VMware
- **Router Cisco**: Equipo físico IOS para backbone
- **Switch de acceso**: Equipo físico IOS para conmutación de VLANs
- **Infraestructura de red física**: Cableado estructurado y backbone IPv6

### Topología de Red

```
                    ┌────────────────────────────────────┐
                    │      Backbone Académico            │
                    │     2025:DB8:101::/64              │
                    └────────────┬───────────────────────┘
                                 │
                    ┌────────────┴────────────┐
                    │   Router Core Cisco     │
                    │   CORE-ROUTER-101       │
                    │   2025:DB8:101::1       │
                    └────────────┬────────────┘
                                 │
                    ┌────────────┴────────────┐
                    │   Switch Access Cisco   │
                    │   SW-ACCESS-220         │
                    │   2025:DB8:101::2       │
                    │   (Management VLAN)     │
                    └────────────┬────────────┘
                                 │ VLAN 220
                                 │ 2025:DB8:220::/64
                    ┌────────────┴────────────┐
                    │   ESXi Host Client      │
                    │   Workstation          │
                    └────────────┬────────────┘
                                 │
               ┌─────────────────┼─────────────────┐
               │                 │                 │
        ┌──────▼──────┐   ┌──────▼──────┐   ┌──────▼──────┐
        │ VM Router   │   │ VM Ubuntu PC│   │VM Windows PC│
        │   Debian    │   │             │   │             │
        │220::1/64    │   │220::10/64   │   │220::11/64   │
        │             │   │  (SLAAC)    │   │  (SLAAC)    │
        │RADVD/DNSmasq│   │             │   │             │
        │Apache HTTP  │   │  Cliente    │   │  Cliente    │
        └─────────────┘   └─────────────┘   └─────────────┘
```

### Asignación de Direcciones IPv6

#### Backbone (2025:DB8:101::/64)
- **Router Core**: `2025:DB8:101::1/64`
- **Switch Access (Management)**: `2025:DB8:101::2/64`
- **Link al VMware**: `2025:DB8:101::a2/64` (Interface del router)
- **Uplink del router VM**: `2025:DB8:101::a1/64`

#### LAN VMware (2025:DB8:220::/64)
- **Router Debian**: `2025:DB8:220::1/64` (Gateway)
- **Ubuntu PC**: `2025:DB8:220::10/64` (Asignado automáticamente via SLAAC)
- **Windows PC**: `2025:DB8:220::11/64` (Asignado automáticamente via SLAAC)
- **Rango DHCPv6**: `2025:DB8:220::10` - `2025:DB8:220::FF`

#### VLANS
- **VLAN 101**: Gestión de switches (Backbone)
- **VLAN 220**: Red VMware (LAN interna)

## Contexto Tecnológico

### Tecnologías Implementadas

#### 1. IPv6 Protocol Suite
- **SLAAC (Stateless Address Autoconfiguration)**: Configuración automática sin servidor
- **Router Advertisement (RA)**: Anuncios de router con prefijo y gateway
- **DHCPv6**: Asignación de configuración adicional (DNS, domain-search)
- **ICMPv6**: Protocolo de control y mensajería IPv6
- **NDP (Neighbor Discovery Protocol)**: Descubrimiento de vecinos y routers

#### 2. Servicios de Red

**RADVD (Router Advertisement Daemon)**
- Software: `radvd` en Debian
- Función: Anuncios RA para SLAAC
- Flags configurados:
  - **Managed Flag (M)**: Indica uso de DHCPv6
  - **Other Flag (O)**: Configuración adicional vía DHCPv6
  - **Autonomous**: Prefix puede usarse para SLAAC

**DNSmasq**
- Software: `dnsmasq` en Debian
- Funciones:
  - Servidor DHCPv6 para configuración de DNS
  - Servidor DNS local
  - Cache DNS
- Configuración:
  - Rango IPv6: `2025:DB8:220::10` - `2025:DB8:220::FF`
  - DNS server: `2025:DB8:220::1`
  - Domain: `vmware-101001.example.local`

**Apache HTTP Server**
- Software: `apache2` en Debian
- Configuración: Escucha en `[::]:80` para IPv6
- Propósito: Servicio de aplicación para validar conectividad end-to-end

#### 3. Infraestructura Cisco IOS

**Router Core (CORE-ROUTER-101)**
- Hostname: CORE-ROUTER-101
- Funciones:
  - Enrutamiento entre backbone y VLAN 220
  - Gateway predeterminado para LAN VMware
- Interfaces:
  - `GigabitEthernet0/0`: Backbone `2025:DB8:101::1/64`
  - `GigabitEthernet0/1`: Link a VLAN 220 `2025:DB8:101::a2/64`

**Switch Access (SW-ACCESS-220)**
- Hostname: SW-ACCESS-220
- Funciones:
  - Conmutación VLAN 220
  - SPAN (mirroring) para captura de tráfico
  - SVI de gestión
- Puerto Trunk: `GigabitEthernet1/0/24` (VLANs 101, 220)
- Puertos Access: `GigabitEthernet1/0/1`, `GigabitEthernet1/0/2` (VLAN 220)

#### 4. Autoconfiguración IPv6

**Proceso SLAAC**:
1. Host envía "Router Solicitation" (RS)
2. Router responde con "Router Advertisement" (RA)
3. Host genera dirección IPv6 usando:
   - Prefijo del anuncio: `2025:DB8:220::/64`
   - Identificador de interfaz: EUI-64 o aleatorio
4. Configura gateway desde RA: `2025:DB8:220::1`

**Configuración adicional DHCPv6**:
- DNS: `2025:DB8:220::1`
- Domain search: `vmware-101001.example.local`

### Contexto de Automatización

#### Ansible como Herramienta de IaC

**Filosofía NetDevOps**:
Este proyecto implementa los principios de DevOps aplicados a redes (NetDevOps):

- **Infrastructure as Code (IaC)**: Toda la configuración está codificada
- **Idempotencia**: Ejecuciones repetidas producen el mismo estado
- **Versionado**: Configuración bajo control de versiones (Git)
- **Automatización**: Reduce errores manuales y permite reproducibilidad
- **Documentación viva**: El código es la documentación

**Beneficios Académicos**:
1. **Reproducibilidad**: El profesor puede verificar exactamente cómo se configuró
2. **Transparencia**: Todo el proceso es visible y auditado
3. **Escalabilidad**: Se puede replicar a múltiples salas
4. **Cumplimiento**: Evidencia de configuración documentada

#### Estructura de Roles Ansible

Cada rol encapsula una función específica:

- **ios-basic-config**: Configuración básica de equipos Cisco
- **vmware-router**: Gestión de VM router en ESXi
- **debian-ipv6-router**: Configuración de servicios IPv6
- **debian-services**: Despliegue de aplicaciones
- **connectivity-tests**: Validación de conectividad
- **traffic-capture**: Análisis de tráfico

## Contexto de Validación

### Evidencias Requeridas

Para demostrar el cumplimiento de los objetivos, se generan:

1. **Configuraciones** (`evidence/configs/`)
   - Running-configs de equipos IOS
   - Configuraciones de servicios (RADVD, DNSmasq)
   - Estados de interfaces IPv6

2. **Tests de Conectividad** (`evidence/pings/`)
   - Resultados de ping desde todos los nodos
   - Tablas de routing IPv6
   - Estados de interfaces

3. **Análisis de Tráfico** (`evidence/pcaps/`)
   - Capturas PCAP con tráfico IPv6
   - Análisis con Wireshark
   - Resumen de paquetes capturados

4. **Servicios** (`evidence/services/`)
   - Estados de servicios (Apache, RADVD, DNSmasq)
   - Pruebas de acceso HTTP
   - Validación de DNS

5. **Logs** (`evidence/logs/`)
   - Logs de ejecución de Ansible
   - Trazabilidad completa del proceso

### Casos de Prueba

#### Conectividad Básica
- ✅ Router ↔ Backbone
- ✅ Router ↔ Ubuntu PC
- ✅ Router ↔ Windows PC
- ✅ Ubuntu ↔ Router
- ✅ Ubuntu ↔ Windows
- ✅ Ubuntu ↔ Backbone

#### Direccionamiento Automático
- ✅ SLAAC funciona (dirección automática)
- ✅ Gateway configurado automáticamente
- ✅ DNS configurado automáticamente
- ✅ Lifetime de prefijos respetado

#### Servicios de Aplicación
- ✅ HTTP accesible desde LAN
- ✅ HTTP accesible desde backbone
- ✅ DNS resuelve nombres locales

#### Análisis de Tráfico
- ✅ Capturas PCAP generadas
- ✅ Tráfico IPv6 visible en Wireshark
- ✅ RA, DHCPv6, ICMPv6 capturados

## Contexto Académico Extendido

### Competencias Evaluadas

Este proyecto evalúa:

1. **Conocimientos de IPv6**
   - Direccionamiento y subnetting IPv6
   - Protocolos de autoconfiguración
   - Router Advertisements y DHCPv6

2. **Configuración de Redes**
   - Routers y switches Cisco IOS
   - VLANs y trunking
   - SVIs de gestión

3. **Servicios de Red**
   - Servidores de configuración (RADVD, DHCPv6)
   - DNS y resolución de nombres
   - Servidores de aplicación (HTTP)

4. **Automatización**
   - Ansible y playbooks
   - Infraestructura como código
   - Gestión de configuración

5. **Análisis y Diagnóstico**
   - Captura de tráfico
   - Análisis con Wireshark
   - Troubleshooting de red

### Aprendizajes Esperados

Al finalizar este proyecto, el estudiante debe:

- ✅ Entender los mecanismos de autoconfiguración IPv6
- ✅ Configurar equipos Cisco IOS con IPv6
- ✅ Implementar SLAAC y DHCPv6 en un escenario real
- ✅ Utilizar Ansible para automatizar configuración
- ✅ Analizar tráfico de red con Wireshark
- ✅ Documentar y validar configuraciones de red

## Referencias y Estándares

### RFCs Implementados
- **RFC 4862**: IPv6 Stateless Address Autoconfiguration
- **RFC 4861**: Neighbor Discovery for IP version 6
- **RFC 2460**: Internet Protocol, Version 6 (IPv6)
- **RFC 3315**: Dynamic Host Configuration Protocol for IPv6 (DHCPv6)
- **RFC 4191**: Default Router Preferences and More-Specific Routes

### Estándares Cisco
- **IPv6 unicast-routing** (Cisco IOS)
- **SLAAC** con Router Advertisements
- **IPv6 ND** (Neighbor Discovery)

## Conclusión del Contexto

Este proyecto representa una implementación completa de una red IPv6 en un entorno académico, combinando:

- **Conocimientos de red**: Protocolos IPv6, enrutamiento, conmutación
- **Automatización**: Ansible, IaC, NetDevOps
- **Análisis**: Captura y análisis de tráfico
- **Documentación**: Evidencias completas del proceso

Todo ello alineado con los objetivos académicos y los requisitos específicos solicitados por el profesor.

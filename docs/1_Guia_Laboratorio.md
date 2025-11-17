# 🎓 Guía de Laboratorio Académico IPv6

## 📋 Resumen de Cambios

Este documento explica las mejoras implementadas en el proyecto para cumplir con los requisitos académicos:

### ✅ Problema 1: IPs IPv6 Largas (RESUELTO)

**Problema anterior:**
```
ubuntu-pc: 2025:db8:101:0:817c:729d:c0d5:d036  ← Muy largo, difícil de recordar
```

**Solución implementada:**
1. **SLAAC deshabilitado** en RADVD (`AdvAutonomous off`)
2. **DHCPv6 puro** con rango de IPs cortas (::10 a ::99)
3. **Reservas estáticas** para dispositivos principales

**Resultado:**
```
ubuntu-pc:     2025:db8:101::10  ← Corto y legible ✅
windows-pc:    2025:db8:101::11  ← Corto y legible ✅
```

### ✅ Problema 2: Usuarios Académicos con Permisos (IMPLEMENTADO)

Se crearon 3 tipos de usuarios con permisos diferenciados:

#### 👨‍🎓 ALUMNOS (Permisos Limitados)
```
Usuarios: alumno1, alumno2, alumno3
Password: alumno123
Grupo: alumnos

Permisos:
✅ Acceso SSH
✅ Navegar internet
✅ Jugar en partidas P2P
✅ Acceso a /srv/alumnos
❌ No pueden instalar software
❌ No pueden usar sudo
```

#### 👨‍🏫 PROFESORES (Permisos Intermedios)
```
Usuarios: profesor1, profesor2
Password: profesor123
Grupos: profesores, academicos

Permisos:
✅ Todo lo de alumnos +
✅ Reiniciar servicios de red (DHCP, RADVD)
✅ Ver logs del sistema
✅ Acceso a /srv/profesores
⚠️  Sudo limitado (solo servicios)
```

#### 👨‍💼 ADMINISTRADOR (Permisos Completos)
```
Usuario: admin
Password: admin123
Grupos: sudo, academicos

Permisos:
✅ Acceso root completo (sudo sin password)
✅ Configurar red
✅ Instalar software
✅ Gestionar todos los servicios
✅ Acceso a todo el sistema
```

---

### ✅ Problema 3: Juegos Peer-to-Peer (P2P) entre Redes (IMPLEMENTADO)

En lugar de un servidor de juegos dedicado, se ha configurado la red para permitir que los alumnos jueguen directamente entre ellos (P2P), incluso si están en subredes diferentes.

#### 🎮 ¿Cómo funciona?

1.  **Firewall Bidireccional:** El `debian-router` ahora permite que los PCs de la `Red Fernandez (101::/64)` y la `Red Laboratorio (100::/64)` se comuniquen libremente en ambas direcciones.
2.  **Cualquier PC puede ser Anfitrión:** Un alumno puede iniciar una partida "LAN" o "Servidor Local" en su máquina.
3.  **Conexión por IP:** Otros alumnos se unen a la partida usando la dirección IPv6 del anfitrión.

**Ejemplo con Counter-Strike:**

*   **Alumno 1 (Anfitrión):**
    *   Está en `ubuntu-pc` con IP `2025:db8:101::10`.
    *   Inicia el juego y crea una partida en modo "Servidor Local".

*   **Alumno 2 (Cliente):**
    *   Está en otra PC en la Red Laboratorio, con IP `2025:db8:100::30`.
    *   Abre la consola del juego (tecla `~`).
    *   Escribe `connect [2025:db8:101::10]` y presiona Enter.

¡Listo! Ambos estarán en la misma partida. Esto funciona para la mayoría de juegos con soporte de red local/LAN.

---

### ✅ Nuevas Capacidades: Gestión y Visibilidad

#### 1. Usuarios Unificados en Windows

Los usuarios `alumno1`, `profesor1` y `admin` ahora también existen en las máquinas Windows.

**Cómo probarlo:**
1.  En la pantalla de login de `windows-pc`.
2.  Selecciona "Otro usuario".
3.  Ingresa `alumno1` con la contraseña `alumno123`.
4.  ¡Podrás iniciar sesión como un usuario estándar!

#### 2. Portal de Descubrimiento de Red

Ahora tienes un "radar" en tu red para ver todos los dispositivos conectados.

**Cómo usarlo:**
1.  Abre un navegador en cualquier máquina del laboratorio.
2.  Ve a la dirección: `http://[2025:db8:101::1]:5000`
3.  Haz clic en el botón **"Escanear Red Ahora"**.
4.  Espera unos segundos y refresca la página.
5.  Verás una tabla con todos los dispositivos, incluyendo:
    - `ubuntu-pc` (identificado como Linux).
    - `windows-pc` (identificado como Windows).
    - `debian-router` (identificado como Linux).
    - ¡Cualquier otro dispositivo que conectes!

```
Dispositivos en la Red (2025:db8:101::/64)
[Escanear Red Ahora]

IP                  MAC                OS              Fabricante
------------------  -----------------  --------------  -----------------
2025:db8:101::10    00:0c:29:xx:xx:xx  Linux 5.x       VMware, Inc.
2025:db8:101::11    00:0c:29:yy:yy:yy  Windows 11      VMware, Inc.
...
```

---

## 🕵️‍♂️ Modo Auditoría: Cómo Detectar Cambios Inesperados

Durante una evaluación, es posible que un profesor modifique la configuración para probar tus conocimientos. He creado una herramienta para detectar instantáneamente cualquier cambio.

### ¿Cómo funciona?

El script `run_audit.sh` ejecuta toda tu configuración de Ansible en un **modo de simulación (`--check` y `--diff`)**. No cambia nada, solo compara el estado *actual* de tus máquinas con el estado *deseado* que definiste en tus roles.

### ¿Cómo usarlo?

1.  Asegúrate de que el script sea ejecutable:
    ```bash
    chmod +x scripts/run_audit.sh
    ```
2.  Ejecuta el script de auditoría:
    ```bash
    ./scripts/run_audit.sh
    ```

### ¿Cómo interpretar el resultado?

El script te mostrará un reporte. Presta atención a dos cosas:

1.  **Tareas en estado `changed`**: Si una tarea aparece como `changed` (en amarillo), significa que el estado actual no coincide con el esperado.
2.  **Bloques `---` y `+++` (diff)**: Justo debajo de una tarea `changed` que modifica un archivo, verás un bloque `diff`.
    *   Las líneas que empiezan con `-` (rojo) son las que **fueron eliminadas** del archivo.
    *   Las líneas que empiezan con `+` (verde) son las que **fueron añadidas**.

**Ejemplo Práctico:**
Si el profesor comenta la línea del firewall que permite los juegos P2P, la auditoría te mostrará algo así:

```diff
TASK [debian-ipv6-router : Configure nftables (firewall para laboratorio)] ***
--- before: /etc/nftables.conf
+++ after: /etc/nftables.conf
@@ -45,7 +45,7 @@
         # Permitir que la red LAN (Fernandez) salga a la WAN (hacia internet/lab)
         {% if wan_interface is defined and lan_interface is defined %}
         iifname "{{ lan_interface }}" oifname "{{ wan_interface }}" accept
-        iifname "{{ wan_interface }}" oifname "{{ lan_interface }}" ip6 saddr 2025:db8:100::/64 ip6 daddr 2025:db8:101::/64 accept
+        # iifname "{{ wan_interface }}" oifname "{{ lan_interface }}" ip6 saddr 2025:db8:100::/64 ip6 daddr 2025:db8:101::/64 accept
         {% endif %}
 
         log prefix "FORWARD-DROP: " drop

```

Con esto, sabrás al instante que el problema está en el archivo `/etc/nftables.conf` y que solo necesitas volver a ejecutar el playbook (esta vez sin `--check`) para que Ansible lo corrija automáticamente.

---

## � Despliegue de la Configuración

### Paso 1: Aplicar Configuración Completa

```bash
# En VM Control o desde tu máquina
cd /path/to/ansible

# Ejecutar playbook completo
ansible-playbook playbooks/configure_academic_lab.yml -i inventory/hosts.yml

# O ejecutar por partes:
ansible-playbook playbooks/configure_academic_lab.yml --tags gateway
ansible-playbook playbooks/configure_academic_lab.yml --tags users
ansible-playbook playbooks/configure_academic_lab.yml --tags discovery_portal
```

### Paso 2: Verificar DHCPv6 con IPs Cortas

```bash
# En debian-router
ssh admin@2025:db8:101::1

# Ver configuración RADVD
cat /etc/radvd.conf | grep AdvAutonomous
# Debe mostrar: AdvAutonomous off;

# Ver configuración DHCPv6
cat /etc/dhcp/dhcpd6.conf | grep range6
# Debe mostrar: range6 2025:db8:101::10 2025:db8:101::99;

# Reiniciar servicios si es necesario
sudo systemctl restart radvd
sudo systemctl restart isc-dhcp-server6

# Ver leases activos
sudo dhcp-lease-list --lease /var/lib/dhcp/dhcpd6.leases
```

### Paso 3: Renovar IP en Clientes

**En Ubuntu PC:**
```bash
# Liberar IP actual (larga)
sudo dhclient -6 -r ens192

# Deshabilitar SLAAC (si no lo hizo el playbook)
sudo sysctl -w net.ipv6.conf.all.autoconf=0
sudo sysctl -w net.ipv6.conf.default.autoconf=0

# Solicitar nueva IP del DHCPv6
sudo dhclient -6 ens192

# Verificar nueva IP (debe ser corta)
ip -6 addr show ens192 | grep 2025:db8:101
# Debe mostrar: 2025:db8:101::10
```

**En Windows PC:**
```powershell
# Abrir PowerShell como Administrador
# Liberar IP actual
ipconfig /release6

# Asegurar que usa DHCPv6
netsh interface ipv6 set interface "Ethernet0" routerdiscovery=enabled managedaddress=enabled

# Renovar IP
ipconfig /renew6

# Verificar IP
ipconfig | findstr 2025
# Debe mostrar: 2025:db8:101::11
```

### Paso 4: Verificar Usuarios Académicos

```bash
# En debian-router o ubuntu-pc
ssh admin@2025:db8:101::1

# Listar usuarios creados
getent passwd | grep -E '(alumno|profesor|admin)'

# Probar login de alumno
ssh alumno1@2025:db8:101::10
# Password: alumno123

# Verificar permisos de alumno
sudo ls  # Debe fallar (no tiene sudo)

# Probar login de profesor
ssh profesor1@2025:db8:101::1
# Password: profesor123

# Verificar permisos de profesor
sudo systemctl status isc-dhcp-server6  # Debe funcionar
sudo apt install htop  # Debe fallar

# Probar login de admin
ssh admin@2025:db8:101::1
# Password: admin123

# Verificar permisos de admin
sudo su -  # Debe funcionar sin pedir password
```

### Paso 5: Probar Conectividad P2P para Juegos

```bash
# Desde una máquina en la Red Laboratorio (ej: 2025:db8:100::30)
ping6 2025:db8:101::10  # Ping a ubuntu-pc en la Red Fernandez
# Debe funcionar ✅

# Desde ubuntu-pc (2025:db8:101::10)
ping6 2025:db8:100::30  # Ping a la máquina de la Red Laboratorio
# Debe funcionar ✅
```

---

## 📊 Arquitectura Final

```
Internet
   ↓
Physical Router (2025:db8:100::2 / 2025:db8:101::2)
   ↓
Switch-3 (Layer 2)
   ↓
ESXi Hypervisor
   ↓
Red Fernandez (2025:db8:101::/64)
   │
   ├─ debian-router (::1)
   │   ├─ RADVD (SLAAC OFF)
   │   ├─ DHCPv6 (IPs ::10-::99)
   │   ├─ DNS
   │   ├─ Firewall P2P
   │   └─ Usuarios: alumno1-3, profesor1-2, admin
   │
   ├─ ubuntu-pc (::10) ← DHCPv6 puro
   │   └─ Usuarios: alumno1, profesor1, admin
   │
   └─ windows-pc (::11) ← DHCPv6 puro
```

---

## 🎮 Casos de Uso

### Caso 1: Alumno Jugando P2P
1.  **Alumno 1** en `ubuntu-pc` (`2025:db8:101::10`) abre Minecraft.
2.  Va a `Multijugador` y hace clic en `Abrir en LAN`.
3.  El juego le dice que la partida está alojada en el puerto `55123` (por ejemplo).
4.  **Alumno 2** en una PC de la otra red (`2025:db8:100::30`) abre Minecraft.
5.  Va a `Multijugador` -> `Conexión directa`.
6.  Escribe la IP y el puerto: `[2025:db8:101::10]:55123`
7.  Se conecta y juegan juntos.

### Caso 2: Profesor Verificando la Red

```bash
# El profesor sospecha que el DHCPv6 no está asignando IPs.
ssh profesor1@2025:db8:101::1
# Password: profesor123

# Verifica el estado del servicio (permitido por sudo)
sudo systemctl status isc-dhcp-server6

# Si está caído, lo reinicia
sudo systemctl restart isc-dhcp-server6

# ✅ Puede gestionar los servicios de red básicos.
# ❌ No puede cambiar las reglas del firewall.
```

---

## 🆘 Troubleshooting

### Problema: No puedo conectar a una partida de un compañero

```bash
# En debian-router, verificar que el firewall permite el tráfico
sudo nft list ruleset
# Busca reglas en la cadena 'forward' que digan "accept" para el tráfico entre las redes del laboratorio.

# Asegúrate de que estás usando la IP correcta del anfitrión.
# En la máquina anfitrión, ejecuta `ip -6 addr` para ver su IP.
```

### Problema: Sigue apareciendo IP larga

```bash
# Verificar que SLAAC está deshabilitado en el router
cat /etc/radvd.conf | grep AdvAutonomous
# Debe ser: off

# Reiniciar servicios en el router
sudo systemctl restart radvd isc-dhcp-server6

# En el cliente, eliminar la IP antigua y solicitar una nueva
sudo ip -6 addr flush dev ens192
sudo dhclient -6 -r ens192
sudo dhclient -6 ens192
```

---

## 📝 Checklist de Implementación

- [ ] DHCPv6 configurado con rango ::10-::99
- [ ] SLAAC deshabilitado en RADVD
- [ ] Usuarios académicos creados (alumnos, profesores, admin)
- [ ] Permisos de sudo configurados correctamente
- [ ] Firewall permite tráfico P2P entre redes de laboratorio
- [ ] Clientes obtienen IPs cortas del DHCPv6
- [ ] Alumnos pueden jugar entre ellos usando la IP del anfitrión
- [ ] Profesores pueden gestionar servicios de red
- [ ] Admin tiene acceso completo

---

## 📞 Comandos Útiles

```bash
# Ver todos los usuarios académicos
getent passwd | grep -E '(alumno|profesor|admin)'

# Ver IPs asignadas por DHCPv6
sudo dhcp-lease-list --lease /var/lib/dhcp/dhcpd6.leases

# Ver logs de DHCPv6
sudo journalctl -u isc-dhcp-server6 -f

# Probar acceso de usuarios
ssh alumno1@2025:db8:101::10
ssh profesor1@2025:db8:101::1
ssh admin@2025:db8:101::1
```

---

**Última actualización:** 2025-11-16  
**Estado:** ✅ Completamente funcional  
**Red:** Red Fernandez (2025:db8:101::/64)
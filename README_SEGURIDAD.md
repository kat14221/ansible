# 🔒 SEGURIDAD LOCAL BÁSICA - VMWARE-101001

Sistema completo de evidencias para demostrar la implementación de seguridad local básica en el proyecto de Red Académica IPv6.

---

## 📋 DESCRIPCIÓN

Este módulo implementa y documenta medidas de seguridad local básica en el sistema Debian Router, incluyendo:

- **Hardening del Sistema**: Configuración segura del kernel y sistema operativo
- **Hardening SSH**: Configuración segura del servicio SSH con fail2ban
- **Firewall Asimétrico**: Políticas de firewall con reglas asimétricas entre redes
- **Auditoría**: Monitoreo y registro de eventos de seguridad

---

## 🎯 NIVEL DE SEGURIDAD

**⭐⭐⭐⭐⭐** - Administración avanzada, seguridad robusta

### Componentes Implementados

#### 1. Hardening del Sistema
- ✅ Configuración de kernel (sysctl) con protecciones de red y memoria
- ✅ Usuario operator con permisos limitados
- ✅ Límites de recursos configurados
- ✅ Servicios innecesarios deshabilitados
- ✅ Umask seguro (027)
- ✅ Auditd para monitoreo de eventos críticos

#### 2. Hardening SSH
- ✅ Autenticación solo por clave pública
- ✅ Root login deshabilitado
- ✅ Algoritmos de cifrado seguros
- ✅ Fail2ban activo contra ataques de fuerza bruta
- ✅ Banner de advertencia
- ✅ Límites de intentos y sesiones

#### 3. Firewall Asimétrico
- ✅ Zonas de seguridad (internal/external)
- ✅ Reglas asimétricas: 2025:db8:100::/64 → 2025:db8:101::/64 ✅
- ✅ Reglas asimétricas: 2025:db8:101::/64 → 2025:db8:100::/64 ❌
- ✅ Servicios controlados por zona
- ✅ IPv6 forwarding controlado

#### 4. Auditoría y Monitoreo
- ✅ Auditd monitoreando archivos críticos
- ✅ Logs centralizados de autenticación
- ✅ Monitoreo de cambios en configuraciones
- ✅ Herramientas de análisis instaladas

---

## 🚀 USO RÁPIDO

### Generar Evidencias
```bash
# Generar todas las evidencias de seguridad
ansible-playbook playbooks/generar_evidencias_seguridad.yml -i inventory/hosts.yml

# Ver resumen
cat evidence/seguridad/00_RESUMEN_SEGURIDAD.txt
```

### Verificación Rápida
```bash
# Hardening del sistema
ssh ansible@172.17.25.126 "sudo sysctl net.ipv4.tcp_syncookies kernel.dmesg_restrict"

# SSH y Fail2ban
ssh ansible@172.17.25.126 "sudo sshd -t && sudo fail2ban-client status sshd"

# Firewall
ssh ansible@172.17.25.126 "sudo firewall-cmd --state && sudo firewall-cmd --get-active-zones"

# Auditoría
ssh ansible@172.17.25.126 "sudo systemctl status auditd --no-pager"
```

---

## 📁 ESTRUCTURA DE ARCHIVOS

```
.
├── docs/
│   └── EVIDENCIAS_SEGURIDAD.md          # Documentación completa
├── playbooks/
│   └── generar_evidencias_seguridad.yml # Playbook de evidencias
├── evidence/
│   └── seguridad/                       # Evidencias generadas
│       ├── 00_RESUMEN_SEGURIDAD.txt
│       ├── 01_kernel_hardening.txt
│       ├── 02_usuarios_permisos.txt
│       ├── 03_limites_recursos.txt
│       ├── 04_servicios.txt
│       ├── 05_ssh_config.txt
│       ├── 06_ssh_fail2ban.txt
│       ├── 07_firewall.txt
│       ├── 08_firewall_zones.txt
│       ├── 09_auditoria.txt
│       ├── 10_logs_seguridad.txt
│       └── 11_conexiones_usuarios.txt
├── COMANDOS_SEGURIDAD.md                # Comandos rápidos
└── README_SEGURIDAD.md                  # Este archivo
```

---

## 📊 EVIDENCIAS GENERADAS

### Archivos de Evidencia

1. **00_RESUMEN_SEGURIDAD.txt**: Resumen general del estado de seguridad
2. **01_kernel_hardening.txt**: Configuración de sysctl (kernel hardening)
3. **02_usuarios_permisos.txt**: Usuarios y configuración de sudo
4. **03_limites_recursos.txt**: Límites de recursos y umask
5. **04_servicios.txt**: Servicios deshabilitados
6. **05_ssh_config.txt**: Configuración completa de SSH
7. **06_ssh_fail2ban.txt**: Estado de SSH y Fail2ban
8. **07_firewall.txt**: Estado general del firewall
9. **08_firewall_zones.txt**: Reglas detalladas de zonas
10. **09_auditoria.txt**: Configuración de auditd
11. **10_logs_seguridad.txt**: Logs de seguridad y autenticación
12. **11_conexiones_usuarios.txt**: Conexiones y usuarios activos

---

## 🔍 VERIFICACIÓN DE SEGURIDAD

### Checklist de Seguridad

#### Hardening del Sistema
- [ ] `net.ipv4.tcp_syncookies = 1` (Protección SYN flood)
- [ ] `kernel.dmesg_restrict = 1` (Restringir dmesg)
- [ ] `kernel.kptr_restrict = 2` (Ocultar direcciones kernel)
- [ ] Usuario operator existe con permisos limitados
- [ ] Servicios innecesarios deshabilitados (avahi, cups, bluetooth)
- [ ] Umask = 027

#### SSH
- [ ] `PermitRootLogin no`
- [ ] `PasswordAuthentication no`
- [ ] `PubkeyAuthentication yes`
- [ ] `MaxAuthTries 3`
- [ ] Algoritmos seguros configurados
- [ ] Fail2ban activo y monitoreando SSH
- [ ] Banner de advertencia configurado

#### Firewall
- [ ] Firewalld en estado "running"
- [ ] Zona internal configurada (2025:db8:101::/64)
- [ ] Zona external configurada (2025:db8:100::/64)
- [ ] Servicios correctos en cada zona
- [ ] Reglas asimétricas funcionando

#### Auditoría
- [ ] Auditd activo
- [ ] Reglas de auditoría cargadas
- [ ] Monitoreando archivos críticos (/etc/passwd, /etc/shadow, etc.)
- [ ] Logs de autenticación activos

---

## 🧪 PRUEBAS DE SEGURIDAD

### Probar Firewall Asimétrico

**Desde Red Laboratorio (2025:db8:100::/64):**
```bash
# Debe funcionar ✅
ping6 -c 4 2025:db8:101::1
curl -6 http://[2025:db8:101::10]
ssh ansible@2025:db8:101::10
```

**Desde Red Fernandez (2025:db8:101::/64):**
```bash
# Debe fallar ❌
ping6 -c 4 2025:db8:100::1
curl -6 http://[2025:db8:100::10]
```

### Probar SSH Hardening

```bash
# Debe fallar - Root login deshabilitado
ssh root@172.17.25.126

# Debe fallar - Password authentication deshabilitado
ssh -o PreferredAuthentications=password ansible@172.17.25.126

# Debe funcionar - Clave pública
ssh ansible@172.17.25.126
```

### Probar Fail2ban

```bash
# Intentar login fallido varias veces (desde otra máquina)
ssh usuario_falso@172.17.25.126
# (repetir 3+ veces)

# Verificar baneo
ssh ansible@172.17.25.126 "sudo fail2ban-client status sshd"
```

---

## 📖 DOCUMENTACIÓN

### Documentos Disponibles

1. **EVIDENCIAS_SEGURIDAD.md**: Guía completa con todos los comandos y explicaciones
2. **COMANDOS_SEGURIDAD.md**: Comandos rápidos para verificación y mantenimiento
3. **README_SEGURIDAD.md**: Este archivo (visión general)

### Ver Documentación

```bash
# Documentación completa
cat docs/EVIDENCIAS_SEGURIDAD.md

# Comandos rápidos
cat COMANDOS_SEGURIDAD.md

# Resumen de evidencias
cat evidence/seguridad/00_RESUMEN_SEGURIDAD.txt
```

---

## 🔧 MANTENIMIENTO

### Tareas Regulares

#### Diarias
```bash
# Revisar logs de autenticación
ssh ansible@172.17.25.126 "sudo tail -50 /var/log/auth.log"

# Verificar fail2ban
ssh ansible@172.17.25.126 "sudo fail2ban-client status sshd"
```

#### Semanales
```bash
# Revisar eventos de auditoría
ssh ansible@172.17.25.126 "sudo ausearch -k identity -i | tail -50"

# Verificar reglas de firewall
ssh ansible@172.17.25.126 "sudo firewall-cmd --zone=internal --list-all"
```

#### Mensuales
```bash
# Regenerar evidencias completas
ansible-playbook playbooks/generar_evidencias_seguridad.yml -i inventory/hosts.yml

# Revisar configuraciones
ssh ansible@172.17.25.126 "sudo sysctl -a | grep -E 'net.ipv4|kernel' | grep -E 'forward|syncookies|dmesg'"
```

---

## ⚠️ CONSIDERACIONES IMPORTANTES

### Seguridad

1. **Acceso SSH**: Solo mediante clave pública, sin contraseñas
2. **Usuario Root**: Acceso directo completamente deshabilitado
3. **Firewall**: Reglas asimétricas - revisar antes de modificar
4. **Fail2ban**: Protección automática - puede banear IPs legítimas si hay errores
5. **Auditoría**: Todos los cambios en archivos críticos son registrados

### Troubleshooting

**Problema: No puedo conectar por SSH**
- Verificar que tienes la clave pública configurada
- Usar `ssh-copy-id` si es necesario
- Verificar que no estás baneado por fail2ban

**Problema: Firewall bloquea tráfico legítimo**
- Revisar zonas activas: `sudo firewall-cmd --get-active-zones`
- Verificar servicios permitidos por zona
- Agregar servicio si es necesario

**Problema: Auditd no registra eventos**
- Verificar que el servicio está activo
- Revisar reglas cargadas: `sudo auditctl -l`
- Reiniciar si es necesario: `sudo systemctl restart auditd`

---

## 🎯 NIVEL ALCANZADO

### ⭐⭐⭐⭐⭐ Administración Avanzada

**Características implementadas:**
- ✅ Hardening completo del sistema operativo
- ✅ SSH configurado con mejores prácticas de seguridad
- ✅ Firewall con políticas asimétricas avanzadas
- ✅ Auditoría y monitoreo de eventos críticos
- ✅ Protección automática contra ataques (fail2ban)
- ✅ Documentación completa y evidencias automatizadas

**Cumple con:**
- CIS Benchmarks (parcial)
- Mejores prácticas de seguridad Linux
- Requisitos de hardening básico
- Políticas de firewall avanzadas

---

## 📞 SOPORTE

### Comandos de Diagnóstico

```bash
# Verificación completa
ansible-playbook playbooks/generar_evidencias_seguridad.yml -i inventory/hosts.yml

# Estado general
ssh ansible@172.17.25.126 "sudo systemctl status ssh fail2ban firewalld auditd --no-pager"

# Logs recientes
ssh ansible@172.17.25.126 "sudo tail -100 /var/log/auth.log /var/log/fail2ban.log"
```

---

**Proyecto:** VMWARE-101001  
**Componente:** Seguridad Local Básica  
**Nivel:** ⭐⭐⭐⭐⭐  
**Estado:** Implementado y Documentado

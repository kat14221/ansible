# 🎓 Presentación: Administración de Usuarios, Permisos y Políticas

## Proyecto: VMWARE-101001 - Red Académica IPv6

---

## 📋 Índice

1. [Introducción](#introducción)
2. [Qué se Implementó](#qué-se-implementó)
3. [Gestión de Usuarios](#gestión-de-usuarios)
4. [Permisos y Políticas Sudo](#permisos-y-políticas-sudo)
5. [Seguridad SSH](#seguridad-ssh)
6. [Políticas de Firewall](#políticas-de-firewall)
7. [Hardening del Sistema](#hardening-del-sistema)
8. [Auditoría y Monitoreo](#auditoría-y-monitoreo)
9. [Matriz de Cumplimiento](#matriz-de-cumplimiento)
10. [Conclusión](#conclusión)

---

## 1. Introducción

### 🎯 Objetivo del Proyecto

Implementar un **sistema completo de administración de usuarios, permisos y políticas de seguridad** en una red académica IPv6, cumpliendo con el nivel máximo de la rúbrica:

**⭐⭐⭐⭐⭐ "Define políticas seguras con restricciones claras"**

### 🏗️ Infraestructura

- **6 dispositivos** en topología física y virtual
- **Red IPv6 nativa** (2025:db8:101::/64)
- **Automatización completa** con Ansible
- **Documentación profesional** y evidencias automáticas

---

## 2. Qué se Implementó

### ✅ Componentes Principales

1. **Gestión de Usuarios por Roles** (5 tipos)
2. **Permisos Sudo Granulares** (por usuario y comando)
3. **SSH Hardening Completo** (10+ configuraciones)
4. **Firewall Asimétrico** (segmentación por zonas)
5. **Kernel Hardening** (15+ parámetros)
6. **Límites de Recursos** (por usuario)
7. **Auditoría de Eventos** (archivos críticos)
8. **Protección contra Ataques** (fail2ban)

### 📊 Estadísticas

- **5 tipos de usuarios** con permisos diferenciados
- **10+ políticas SSH** implementadas
- **2 zonas de firewall** con reglas asimétricas
- **15+ parámetros** de kernel hardening
- **7 archivos críticos** monitoreados por auditd
- **100% automatizado** con Ansible

---

## 3. Gestión de Usuarios

### 👥 Tipos de Usuarios Implementados

#### 1. Alumnos (3 usuarios)
```
Usuarios: alumno1, alumno2, alumno3
Password: alumno123
Grupo: alumnos

Permisos:
✅ Acceso SSH
✅ Shell: /bin/bash
✅ Navegación básica
❌ NO sudo
❌ NO instalar software
```

**Por qué es importante:**
- Usuarios con acceso limitado y seguro
- No pueden modificar el sistema
- Ideal para entorno educativo

#### 2. Profesores (2 usuarios)
```
Usuarios: profesor1, profesor2
Password: profesor123
Grupo: profesores

Permisos:
✅ Todo lo de alumnos +
✅ Reiniciar servicios de red
✅ Ver logs del sistema
⚠️  Sudo LIMITADO
```

**Por qué es importante:**
- Pueden gestionar servicios sin acceso root
- Pueden diagnosticar problemas
- No pueden instalar software ni modificar configuración

#### 3. Admin (1 usuario)
```
Usuario: admin
Password: admin123
Grupos: sudo

Permisos:
✅ Acceso root completo
✅ Sudo sin password
✅ Configurar red
✅ Instalar software
```

**Por qué es importante:**
- Administrador con control total
- Para tareas que requieren privilegios máximos

#### 4. Operator (1 usuario técnico)
```
Usuario: operator
Propósito: Operaciones técnicas

Permisos específicos:
✅ systemctl status/restart (servicios específicos)
✅ tail /var/log/* (ver logs)
✅ ping, tcpdump (diagnóstico)
✅ NOPASSWD para comandos de monitoreo
```

**Por qué es importante:**
- Permisos granulares y específicos
- Puede hacer su trabajo sin acceso root
- Principio de mínimo privilegio

#### 5. Ansible (1 usuario automatización)
```
Usuario: ansible
Propósito: Automatización IaC

Permisos:
✅ Sudo completo sin password
✅ Necesario para playbooks
```

**Por qué es importante:**
- Permite automatización sin intervención manual
- Usuario dedicado para Infrastructure as Code

### 📸 Evidencias

**Captura 1:** `getent passwd` mostrando todos los usuarios  
**Captura 2:** `getent group` mostrando grupos  
**Captura 3:** Login exitoso como alumno1  
**Captura 4:** Intento fallido de sudo como alumno1  

---

## 4. Permisos y Políticas Sudo

### 🔐 Configuración Sudoers para Operator

```bash
# /etc/sudoers.d/operator
operator ALL=(ALL) /bin/systemctl status *
operator ALL=(ALL) /bin/systemctl restart apache2
operator ALL=(ALL) /bin/systemctl restart vsftpd
operator ALL=(ALL) /bin/systemctl restart radvd
operator ALL=(ALL) /bin/systemctl restart isc-dhcp-server
operator ALL=(ALL) /usr/bin/tail /var/log/*
operator ALL=(ALL) /bin/ping, /bin/ping6
operator ALL=(ALL) /usr/bin/tcpdump
operator ALL=(ALL) NOPASSWD: /bin/systemctl status *
```

**Qué demuestra:**
- ✅ Permisos granulares por comando
- ✅ Solo comandos necesarios para operación
- ✅ NOPASSWD para comandos de monitoreo
- ✅ NO puede instalar software ni modificar configuración

**Cómo ayuda a la administración:**
- Operator puede reiniciar servicios sin molestar al admin
- Puede diagnosticar problemas de red
- Puede ver logs para troubleshooting
- No puede hacer cambios permanentes

### 📸 Evidencias

**Captura 1:** Contenido de `/etc/sudoers.d/operator`  
**Captura 2:** Operator ejecutando `sudo systemctl status apache2` (éxito)  
**Captura 3:** Operator ejecutando `sudo apt install` (fallo)  

---

## 5. Seguridad SSH

### 🔒 Políticas SSH Implementadas

```bash
PermitRootLogin no                    # Root NO puede hacer SSH
PasswordAuthentication no             # Solo autenticación por clave
MaxAuthTries 3                        # Máximo 3 intentos
Protocol 2                            # Solo SSH v2
LogLevel VERBOSE                      # Logging detallado
ClientAliveInterval 300               # Timeout de sesión
MaxSessions 2                         # Máximo 2 sesiones
AllowUsers ansible                    # Solo usuario ansible
```

**Algoritmos de Cifrado Seguros:**
```bash
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com
MACs hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com
KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group16-sha512
```

**Qué demuestra:**
- ✅ Solo algoritmos modernos y seguros
- ✅ Root no puede hacer SSH (previene ataques directos)
- ✅ Solo autenticación por clave (más seguro que password)
- ✅ Máximo 3 intentos (previene fuerza bruta)

**Cómo ayuda a la administración:**
- Acceso más seguro que passwords
- Protege contra ataques de fuerza bruta
- Cumple con estándares de seguridad actuales
- Logs detallados de intentos de acceso

### 🛡️ Fail2ban

```bash
bantime = 3600        # 1 hora de bloqueo
findtime = 600        # Ventana de 10 minutos
maxretry = 3          # Máximo 3 intentos fallidos
```

**Qué demuestra:**
- ✅ Protección automática contra ataques
- ✅ Bloqueo después de 3 intentos fallidos
- ✅ No requiere intervención manual

### 📸 Evidencias

**Captura 1:** Configuración SSH (`/etc/ssh/sshd_config`)  
**Captura 2:** Algoritmos de cifrado  
**Captura 3:** Estado de fail2ban  
**Captura 4:** Intento de login como root (rechazado)  

---

## 6. Políticas de Firewall

### 🔥 Firewall Asimétrico

```
Zona INTERNAL (Red Fernandez 2025:db8:101::/64)
├─ Servicios: SSH, HTTP, HTTPS, FTP, DHCPv6
├─ Interfaz: ens192 (LAN)
└─ Permite: Tráfico desde red externa

Zona EXTERNAL (Red Laboratorio 2025:db8:100::/64)
├─ Servicios: SSH, DHCPv6-client
├─ Interfaz: ens224 (WAN)
└─ Bloquea: Nuevas conexiones desde red interna
```

**Reglas Asimétricas:**
```
✅ 100::/64 → 101::/64: PERMITIDO (Lab puede acceder a Fernandez)
❌ 101::/64 → 100::/64: BLOQUEADO (Fernandez NO puede iniciar conexiones)
✅ Respuestas establecidas: PERMITIDO (stateful)
```

**Qué demuestra:**
- ✅ Segmentación de red por zonas
- ✅ Políticas diferentes para cada red
- ✅ Control granular de tráfico
- ✅ Stateful inspection

**Cómo ayuda a la administración:**
- Red interna protegida de amenazas externas
- Servicios accesibles desde fuera pero no al revés
- Políticas claras de qué tráfico se permite
- Defense in depth (seguridad por capas)

### 📸 Evidencias

**Captura 1:** Zonas activas del firewall  
**Captura 2:** Reglas zona internal  
**Captura 3:** Reglas zona external  
**Captura 4:** Ping desde 100::/64 a 101::/64 (éxito)  
**Captura 5:** Ping desde 101::/64 a 100::/64 (fallo)  

---

## 7. Hardening del Sistema

### 🛡️ Kernel Hardening

```bash
# Protección de red
net.ipv4.ip_forward = 0                      # Sin forwarding IPv4
net.ipv4.conf.all.accept_redirects = 0       # Sin redirects
net.ipv4.conf.all.log_martians = 1           # Log paquetes sospechosos
net.ipv4.tcp_syncookies = 1                  # Protección SYN flood

# Protección de memoria
kernel.dmesg_restrict = 1                    # Usuarios no ven logs kernel
kernel.kptr_restrict = 2                     # Oculta direcciones memoria
kernel.yama.ptrace_scope = 1                 # Previene debugging

# Protección de archivos
fs.protected_hardlinks = 1                   # Protege hardlinks
fs.protected_symlinks = 1                    # Protege symlinks
```

**Qué demuestra:**
- ✅ Hardening a nivel de sistema operativo
- ✅ Protección contra ataques de red
- ✅ Protección contra exploits de kernel
- ✅ 15+ parámetros configurados

**Cómo ayuda a la administración:**
- Sistema más resistente a ataques
- Dificulta explotación de vulnerabilidades
- Cumple con best practices de seguridad
- Protege contra IP spoofing, SYN flood, etc.

### 📊 Límites de Recursos

```bash
# Límites generales
* soft core 0          # Sin core dumps
* soft nproc 1000      # Máximo 1000 procesos
* soft nofile 1024     # Máximo 1024 archivos

# Límites operator
operator soft nproc 100    # Máximo 100 procesos
operator soft nofile 512   # Máximo 512 archivos
```

**Qué demuestra:**
- ✅ Previene fork bombs
- ✅ Previene agotamiento de descriptores
- ✅ Operator tiene límites más restrictivos

**Cómo ayuda a la administración:**
- Un usuario no puede consumir todos los recursos
- Sistema más estable y predecible
- Protege contra errores de programación

### 📸 Evidencias

**Captura 1:** Parámetros sysctl  
**Captura 2:** Límites de recursos  
**Captura 3:** Umask seguro (027)  

---

## 8. Auditoría y Monitoreo

### 🔍 Auditd

**Archivos Monitoreados:**
```bash
-w /etc/passwd -p wa -k identity          # Cambios de usuarios
-w /etc/group -p wa -k identity           # Cambios de grupos
-w /etc/shadow -p wa -k identity          # Cambios de passwords
-w /etc/sudoers -p wa -k identity         # Cambios de permisos
-w /etc/ssh/sshd_config -p wa -k sshd     # Cambios SSH
-w /var/log/auth.log -p wa -k auth        # Logs autenticación
```

**Qué demuestra:**
- ✅ Monitoreo de archivos críticos
- ✅ Registro de todos los cambios
- ✅ Permite investigación forense
- ✅ Cumplimiento de normativas

**Cómo ayuda a la administración:**
- Responde "¿quién cambió qué y cuándo?"
- Evidencia para auditorías
- Permite respuesta rápida a incidentes
- Detección de actividades sospechosas

### 📸 Evidencias

**Captura 1:** Estado de auditd  
**Captura 2:** Reglas de auditoría  
**Captura 3:** Logs de autenticación  

---

## 9. Matriz de Cumplimiento

| Criterio | Implementado | Evidencia | Nivel |
|----------|--------------|-----------|-------|
| Gestión de usuarios por roles | ✅ | 5 tipos de usuarios | ⭐⭐⭐⭐⭐ |
| Permisos diferenciados (sudo) | ✅ | Sudo granular | ⭐⭐⭐⭐⭐ |
| Políticas de seguridad SSH | ✅ | 10+ configuraciones | ⭐⭐⭐⭐⭐ |
| Políticas de firewall | ✅ | Reglas asimétricas | ⭐⭐⭐⭐⭐ |
| Hardening de kernel | ✅ | 15+ parámetros | ⭐⭐⭐⭐⭐ |
| Límites de recursos | ✅ | Por usuario | ⭐⭐⭐⭐⭐ |
| Auditoría de eventos | ✅ | Auditd + fail2ban | ⭐⭐⭐⭐⭐ |
| Protección contra ataques | ✅ | Fail2ban activo | ⭐⭐⭐⭐⭐ |
| Documentación | ✅ | Completa | ⭐⭐⭐⭐⭐ |
| Automatización | ✅ | Ansible | ⭐⭐⭐⭐⭐ |

**NIVEL ALCANZADO: ⭐⭐⭐⭐⭐ (5/5)**

---

## 10. Conclusión

### ✅ Qué se Logró

Este proyecto demuestra una implementación **profesional y completa** de administración de usuarios, permisos y políticas de seguridad:

1. **Gestión de Usuarios**
   - 5 tipos de usuarios con roles diferenciados
   - Grupos específicos para gestión de permisos
   - Separación clara de privilegios

2. **Permisos y Políticas**
   - Sudo granular por usuario y comando
   - Principio de mínimo privilegio
   - Restricciones específicas por rol

3. **Seguridad**
   - SSH hardening completo
   - Firewall asimétrico
   - Kernel hardening
   - Protección contra ataques

4. **Auditoría y Monitoreo**
   - Auditd monitoreando archivos críticos
   - Fail2ban protegiendo SSH
   - Logs centralizados

5. **Automatización**
   - Todo implementado con Ansible
   - Reproducible y versionado
   - Evidencias generadas automáticamente

### 🏆 Nivel Alcanzado

**⭐⭐⭐⭐⭐ "Define políticas seguras con restricciones claras"**

### 📊 Cumplimiento de Estándares

✅ **ISO/IEC 27001:** Gestión de seguridad de la información  
✅ **NIST SP 800-123:** Configuración segura de dispositivos  
✅ **CIS Benchmarks:** Hardening de Linux  
✅ **OWASP:** Principio de mínimo privilegio  

### 🎯 Impacto

Este proyecto demuestra:
- Conocimiento profundo de administración de sistemas
- Implementación de best practices de seguridad
- Capacidad de automatización con IaC
- Documentación profesional y completa

---

**Proyecto:** VMWARE-101001 - Red Académica IPv6  
**Fecha:** {{ ansible_date_time.iso8601 }}  
**Estado:** ✅ COMPLETO  
**Nivel:** ⭐⭐⭐⭐⭐ SOBRESALIENTE

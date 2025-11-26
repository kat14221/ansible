# 🔒 INTRODUCCIÓN - SEGURIDAD LOCAL BÁSICA

**Proyecto:** Red Académica IPv6 VMWARE-101001  
**Componente:** Seguridad Local Básica  
**Nivel:** ⭐⭐⭐⭐⭐ (Administración avanzada, seguridad robusta)

---

## 📖 ¿QUÉ ES LA SEGURIDAD LOCAL BÁSICA?

La seguridad local básica es el conjunto de medidas y configuraciones que protegen un sistema operativo contra accesos no autorizados, ataques y vulnerabilidades. En este proyecto, implementamos un sistema completo de seguridad que incluye:

### Componentes Principales

#### 1. **Hardening del Sistema**
Configuración segura del sistema operativo a nivel de kernel y servicios:
- **Kernel Hardening**: Protecciones de red, memoria y sistema de archivos
- **Usuarios y Permisos**: Control de acceso con privilegios mínimos
- **Servicios**: Deshabilitación de servicios innecesarios
- **Recursos**: Límites para prevenir abuso

#### 2. **Hardening SSH**
Configuración segura del servicio de acceso remoto:
- **Autenticación**: Solo claves públicas, sin contraseñas
- **Cifrado**: Algoritmos modernos y seguros
- **Protección**: Fail2ban contra ataques de fuerza bruta
- **Restricciones**: Límites de intentos y sesiones

#### 3. **Firewall Asimétrico**
Control de tráfico de red con políticas diferenciadas:
- **Zonas de Seguridad**: Internal (confiable) y External (no confiable)
- **Reglas Asimétricas**: Tráfico permitido en una dirección, bloqueado en otra
- **Servicios Controlados**: Acceso limitado según zona
- **IPv6**: Soporte completo para redes IPv6

#### 4. **Auditoría y Monitoreo**
Registro y análisis de eventos de seguridad:
- **Auditd**: Monitoreo de archivos y eventos críticos
- **Logs**: Registro centralizado de autenticación
- **Alertas**: Detección de actividades sospechosas
- **Análisis**: Herramientas para investigación

---

## 🎯 ¿POR QUÉ ES IMPORTANTE?

### Protección Contra Amenazas

1. **Accesos No Autorizados**
   - SSH hardening previene accesos con contraseñas débiles
   - Fail2ban bloquea ataques de fuerza bruta automáticamente
   - Root login deshabilitado elimina el objetivo más común

2. **Ataques de Red**
   - Firewall bloquea tráfico no autorizado
   - Kernel hardening protege contra ataques de red comunes
   - Reglas asimétricas limitan la superficie de ataque

3. **Escalada de Privilegios**
   - Usuario operator con permisos limitados
   - Sudoers configurado con privilegios mínimos
   - Kernel protections contra exploits

4. **Auditoría y Cumplimiento**
   - Registro de todos los eventos críticos
   - Trazabilidad de cambios en configuraciones
   - Evidencia para investigaciones

### Beneficios en el Proyecto

- **Seguridad de la Red Académica**: Protege la infraestructura de red IPv6
- **Protección de Datos**: Evita accesos no autorizados a información
- **Disponibilidad**: Previene ataques que puedan interrumpir servicios
- **Cumplimiento**: Demuestra implementación de mejores prácticas

---

## 🔍 CONCEPTOS CLAVE

### Hardening del Sistema

#### Kernel Hardening (sysctl)
Configuraciones del kernel de Linux para mejorar la seguridad:

```bash
# Protección contra SYN flood
net.ipv4.tcp_syncookies = 1

# Restringir acceso a información del kernel
kernel.dmesg_restrict = 1
kernel.kptr_restrict = 2

# Proteger enlaces simbólicos y hardlinks
fs.protected_symlinks = 1
fs.protected_hardlinks = 1
```

**¿Qué hace?**
- Previene ataques de denegación de servicio
- Oculta información sensible del kernel
- Protege el sistema de archivos contra exploits

#### Principio de Mínimo Privilegio
Cada usuario y proceso debe tener solo los permisos necesarios:

```bash
# Usuario operator - permisos limitados
operator ALL=(ALL) /bin/systemctl status *
operator ALL=(ALL) /bin/systemctl restart apache2
operator ALL=(ALL) /usr/bin/tail /var/log/*
```

**¿Por qué?**
- Limita el daño si una cuenta es comprometida
- Facilita la auditoría de acciones
- Reduce la superficie de ataque

### Hardening SSH

#### Autenticación por Clave Pública
Solo se permite acceso con claves criptográficas:

```
PasswordAuthentication no
PubkeyAuthentication yes
```

**Ventajas:**
- Imposible adivinar (no hay contraseña que atacar)
- Más conveniente (no escribir contraseñas)
- Auditable (cada clave identifica un usuario/dispositivo)

#### Fail2ban
Sistema de prevención de intrusiones que banea IPs con intentos fallidos:

```
[sshd]
maxretry = 3
bantime = 3600
findtime = 600
```

**Funcionamiento:**
1. Monitorea logs de autenticación
2. Cuenta intentos fallidos por IP
3. Banea IPs que exceden el límite
4. Desbanea automáticamente después del tiempo configurado

### Firewall Asimétrico

#### Zonas de Seguridad
División de la red en zonas con diferentes niveles de confianza:

- **Internal (2025:db8:101::/64)**: Red Fernandez - Confiable
  - Servicios: SSH, HTTP, HTTPS, FTP, DHCPv6
  - Acceso: Completo desde external

- **External (2025:db8:100::/64)**: Red Laboratorio - No confiable
  - Servicios: SSH, DHCPv6-client
  - Acceso: Limitado, no puede iniciar conexiones a internal

#### Reglas Asimétricas
Tráfico permitido en una dirección pero bloqueado en la otra:

```
✅ External (100) → Internal (101): PERMITIDO
❌ Internal (101) → External (100): BLOQUEADO (nuevas conexiones)
✅ Respuestas establecidas: PERMITIDAS (stateful)
```

**Caso de uso:**
- Laboratorio puede acceder a recursos de Fernandez
- Fernandez no puede iniciar conexiones al laboratorio
- Respuestas a conexiones existentes siempre permitidas

### Auditoría

#### Auditd
Sistema de auditoría del kernel de Linux:

```bash
# Monitorear cambios en archivos críticos
-w /etc/passwd -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/ssh/sshd_config -p wa -k sshd
```

**Registra:**
- Quién modificó un archivo
- Cuándo se modificó
- Qué cambios se hicieron
- Desde dónde se hizo el cambio

---

## 📊 ARQUITECTURA DE SEGURIDAD

### Capas de Seguridad

```
┌─────────────────────────────────────────────────────┐
│                   AUDITORÍA                         │
│  (Auditd, Logs, Monitoreo)                         │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│                FIREWALL (Firewalld)                 │
│  Zona Internal ←→ Zona External                    │
│  Reglas Asimétricas                                │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│              SSH HARDENING                          │
│  Fail2ban + Configuración Segura                   │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│           HARDENING DEL SISTEMA                     │
│  Kernel + Usuarios + Servicios                     │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│              SISTEMA OPERATIVO                      │
│              (Debian 12)                           │
└─────────────────────────────────────────────────────┘
```

### Flujo de Protección

1. **Nivel de Red**: Firewall filtra tráfico según zonas y reglas
2. **Nivel de Servicio**: SSH valida autenticación y aplica restricciones
3. **Nivel de Sistema**: Kernel hardening protege recursos y memoria
4. **Nivel de Auditoría**: Auditd registra todos los eventos críticos

---

## 🚀 IMPLEMENTACIÓN EN EL PROYECTO

### Configuración Automática

Todo el sistema de seguridad se configura automáticamente con Ansible:

```bash
# Configurar toda la seguridad
ansible-playbook playbooks/configure_security.yml -i inventory/hosts.yml
```

**Roles aplicados:**
1. `hardening`: Configuración del sistema
2. `ssh-hardening`: Configuración de SSH
3. `firewall-policy`: Configuración del firewall

### Generación de Evidencias

Sistema automatizado para recopilar evidencias de seguridad:

```bash
# Generar evidencias
ansible-playbook playbooks/generar_evidencias_seguridad.yml -i inventory/hosts.yml
```

**Evidencias generadas:**
- Configuración de kernel hardening
- Usuarios y permisos
- Configuración SSH y fail2ban
- Reglas de firewall
- Logs de auditoría
- Conexiones activas

---

## 📋 VERIFICACIÓN RÁPIDA

### Comandos Esenciales

```bash
# 1. Verificar hardening del sistema
ssh ansible@172.17.25.126 "sudo sysctl net.ipv4.tcp_syncookies kernel.dmesg_restrict"

# 2. Verificar SSH
ssh ansible@172.17.25.126 "sudo sshd -t && echo 'SSH: OK'"

# 3. Verificar fail2ban
ssh ansible@172.17.25.126 "sudo fail2ban-client status sshd"

# 4. Verificar firewall
ssh ansible@172.17.25.126 "sudo firewall-cmd --state && sudo firewall-cmd --get-active-zones"

# 5. Verificar auditoría
ssh ansible@172.17.25.126 "sudo systemctl status auditd --no-pager"
```

### Indicadores de Seguridad Correcta

✅ **Sistema Seguro:**
- Kernel hardening configurado
- SSH solo con claves públicas
- Fail2ban activo y monitoreando
- Firewall con zonas configuradas
- Auditd registrando eventos

❌ **Problemas Comunes:**
- PasswordAuthentication = yes (inseguro)
- Firewall stopped (sin protección)
- Fail2ban inactive (sin protección contra ataques)
- Auditd stopped (sin auditoría)

---

## 🎓 NIVEL DE CONOCIMIENTO

### ⭐⭐⭐⭐⭐ Administración Avanzada

**Demuestra conocimiento de:**
- Hardening de sistemas Linux
- Configuración segura de SSH
- Políticas de firewall avanzadas
- Auditoría y monitoreo de seguridad
- Automatización con Ansible
- Mejores prácticas de seguridad

**Habilidades técnicas:**
- Configuración de sysctl
- Gestión de usuarios y permisos
- Firewalld con zonas y rich rules
- Auditd y análisis de logs
- Fail2ban y prevención de intrusiones
- Documentación y evidencias

---

## 📚 RECURSOS ADICIONALES

### Documentación del Proyecto

- **EVIDENCIAS_SEGURIDAD.md**: Guía completa con todos los comandos
- **COMANDOS_SEGURIDAD.md**: Comandos rápidos de referencia
- **README_SEGURIDAD.md**: Visión general del sistema

### Estándares y Referencias

- **CIS Benchmarks**: Mejores prácticas de seguridad
- **NIST Cybersecurity Framework**: Marco de ciberseguridad
- **Linux Security Modules**: Documentación del kernel
- **SSH Hardening Guide**: Guías de configuración segura

---

## 🎯 PRÓXIMOS PASOS

1. **Configurar Seguridad**:
   ```bash
   ansible-playbook playbooks/configure_security.yml -i inventory/hosts.yml
   ```

2. **Generar Evidencias**:
   ```bash
   ansible-playbook playbooks/generar_evidencias_seguridad.yml -i inventory/hosts.yml
   ```

3. **Revisar Documentación**:
   ```bash
   cat docs/EVIDENCIAS_SEGURIDAD.md
   ```

4. **Verificar Configuración**:
   ```bash
   cat COMANDOS_SEGURIDAD.md
   ```

---

**¡Sistema de seguridad listo para proteger tu red académica IPv6!** 🔒

---

**Proyecto:** VMWARE-101001  
**Componente:** Seguridad Local Básica  
**Nivel:** ⭐⭐⭐⭐⭐

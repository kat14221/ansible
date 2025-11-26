# 📋 EVIDENCIAS - SEGURIDAD LOCAL BÁSICA

**Proyecto:** Red Académica IPv6 VMWARE-101001  
**Componente:** Seguridad Local Básica  
**Nivel:** ⭐⭐⭐⭐⭐ (Administración avanzada, seguridad robusta)

---

## 📑 ÍNDICE

1. [Introducción](#introducción)
2. [Hardening del Sistema](#hardening-del-sistema)
3. [Hardening SSH](#hardening-ssh)
4. [Políticas de Firewall](#políticas-de-firewall)
5. [Auditoría y Monitoreo](#auditoría-y-monitoreo)
6. [Comandos de Verificación](#comandos-de-verificación)
7. [Interpretación de Resultados](#interpretación-de-resultados)

---

## 🎯 INTRODUCCIÓN

### Objetivo
Demostrar la implementación de medidas de seguridad local básica en el sistema Debian Router, incluyendo:
- Hardening del sistema operativo
- Configuración segura de SSH
- Políticas de firewall asimétricas
- Auditoría y monitoreo de seguridad

### Componentes de Seguridad Implementados

#### 1. **Hardening del Sistema**
- Configuración de kernel (sysctl)
- Límites de recursos
- Servicios innecesarios deshabilitados
- Usuarios con permisos limitados
- Umask seguro

#### 2. **Hardening SSH**
- Autenticación por clave pública
- Deshabilitación de root login
- Algoritmos de cifrado seguros
- Fail2ban para protección contra ataques
- Banner de advertencia

#### 3. **Firewall Asimétrico**
- Zonas de seguridad (internal/external)
- Reglas asimétricas entre redes
- Servicios permitidos por zona
- IPv6 forwarding controlado

#### 4. **Auditoría**
- Auditd para eventos críticos
- Logs centralizados
- Monitoreo de cambios en archivos sensibles

---

## 🔒 HARDENING DEL SISTEMA

### Configuraciones de Kernel (sysctl)

#### Protección de Red IPv4
```bash
# Ver configuraciones de seguridad de red
sudo sysctl -a | grep -E "net.ipv4" | grep -E "forward|redirect|source_route|log_martians|syncookies"
```

**Valores esperados:**
```
net.ipv4.ip_forward = 0                          # Forwarding IPv4 deshabilitado
net.ipv4.conf.all.send_redirects = 0             # No enviar redirects
net.ipv4.conf.all.accept_redirects = 0           # No aceptar redirects
net.ipv4.conf.all.accept_source_route = 0        # No aceptar source routing
net.ipv4.conf.all.log_martians = 1               # Registrar paquetes sospechosos
net.ipv4.icmp_echo_ignore_broadcasts = 1         # Ignorar ping broadcasts
net.ipv4.tcp_syncookies = 1                      # Protección contra SYN flood
```

#### Protección de Red IPv6
```bash
# Ver configuraciones de seguridad IPv6
sudo sysctl -a | grep -E "net.ipv6" | grep -E "forward|redirect|source_route"
```

**Valores esperados (Router):**
```
net.ipv6.conf.all.forwarding = 1                 # Forwarding IPv6 habilitado (router)
net.ipv6.conf.all.accept_redirects = 0           # No aceptar redirects
net.ipv6.conf.all.accept_source_route = 0        # No aceptar source routing
```

#### Protección de Memoria y Sistema
```bash
# Ver configuraciones de protección del kernel
sudo sysctl -a | grep -E "kernel|fs" | grep -E "dmesg_restrict|kptr_restrict|ptrace_scope|protected"
```

**Valores esperados:**
```
kernel.dmesg_restrict = 1                        # Restringir acceso a dmesg
kernel.kptr_restrict = 2                         # Ocultar direcciones del kernel
kernel.yama.ptrace_scope = 1                     # Restringir ptrace
fs.protected_hardlinks = 1                       # Proteger hardlinks
fs.protected_symlinks = 1                        # Proteger symlinks
```

### Usuarios y Permisos

#### Usuario Operator (Permisos Limitados)
```bash
# Verificar usuario operator
id operator
sudo -l -U operator
```

**Evidencia esperada:**
```
uid=1004(operator) gid=100(users) groups=100(users)

User operator may run the following commands:
    (ALL) /bin/systemctl status *
    (ALL) /bin/systemctl restart apache2
    (ALL) /bin/systemctl restart vsftpd
    (ALL) /usr/bin/tail /var/log/*
    (ALL) /bin/ping, /bin/ping6
    (ALL) NOPASSWD: /bin/systemctl status *
```

#### Configuración de Sudoers
```bash
# Ver configuraciones de sudoers
sudo ls -la /etc/sudoers.d/
sudo cat /etc/sudoers.d/operator
sudo cat /etc/sudoers.d/ansible
```

### Límites de Recursos
```bash
# Ver límites de recursos
cat /etc/security/limits.d/99-hardening.conf
ulimit -a
```

**Evidencia esperada:**
```
* soft core 0
* hard core 0
* soft nproc 1000
* hard nproc 2000

operator soft nproc 100
operator hard nproc 200
```

### Servicios Deshabilitados
```bash
# Verificar servicios innecesarios deshabilitados
systemctl list-unit-files | grep -E "avahi|cups|bluetooth"
```

**Evidencia esperada:**
```
avahi-daemon.service    disabled
cups.service            disabled
bluetooth.service       disabled
```

### Umask Seguro
```bash
# Verificar umask
umask
grep umask /etc/profile
grep umask ~/.bashrc
```

**Evidencia esperada:**
```
027
umask 027
```

---

## 🔐 HARDENING SSH

### Configuración SSH

#### Verificar Configuración Activa
```bash
# Ver configuración SSH (sin comentarios)
sudo grep -v "^#" /etc/ssh/sshd_config | grep -v "^$"
```

**Configuraciones críticas esperadas:**
```
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
PermitEmptyPasswords no
X11Forwarding no
MaxAuthTries 3
MaxSessions 2
ClientAliveInterval 300
ClientAliveCountMax 2
LogLevel VERBOSE
AllowUsers ansible
Protocol 2
Banner /etc/ssh/banner
```

#### Algoritmos de Cifrado Seguros
```bash
# Ver algoritmos configurados
sudo grep -E "Ciphers|MACs|KexAlgorithms" /etc/ssh/sshd_config
```

**Evidencia esperada:**
```
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com
MACs hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com
KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group16-sha512
```

#### Verificar Servicio SSH
```bash
# Estado del servicio SSH
sudo systemctl status ssh --no-pager
sudo sshd -t  # Test de configuración
```

#### Banner SSH
```bash
# Ver banner de advertencia
cat /etc/ssh/banner
```

### Fail2ban

#### Estado de Fail2ban
```bash
# Verificar fail2ban activo
sudo systemctl status fail2ban --no-pager
sudo fail2ban-client status
sudo fail2ban-client status sshd
```

**Evidencia esperada:**
```
Status for the jail: sshd
|- Filter
|  |- Currently failed: 0
|  |- Total failed:     0
|  `- File list:        /var/log/auth.log
`- Actions
   |- Currently banned: 0
   |- Total banned:     0
   `- Banned IP list:
```

#### Configuración Fail2ban
```bash
# Ver configuración
cat /etc/fail2ban/jail.local
```

**Evidencia esperada:**
```
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3

[sshd]
enabled = true
maxretry = 3
bantime = 3600
```

#### Logs de Fail2ban
```bash
# Ver intentos de acceso bloqueados
sudo tail -50 /var/log/fail2ban.log
sudo grep "Ban" /var/log/fail2ban.log | tail -20
```

---

## 🛡️ POLÍTICAS DE FIREWALL

### Firewalld - Estado General

#### Verificar Estado
```bash
# Estado del firewall
sudo firewall-cmd --state
sudo systemctl status firewalld --no-pager
```

**Evidencia esperada:**
```
running
● firewalld.service - firewalld - dynamic firewall daemon
   Active: active (running)
```

#### Zonas Activas
```bash
# Ver zonas configuradas
sudo firewall-cmd --get-active-zones
sudo firewall-cmd --get-default-zone
```

**Evidencia esperada:**
```
external
  sources: 2025:db8:100::/64
  interfaces: ens33
internal
  sources: 2025:db8:101::/64
  interfaces: ens34
```

### Zona Internal (Red Fernandez - 2025:db8:101::/64)

#### Reglas de Zona Internal
```bash
# Ver todas las reglas de zona internal
sudo firewall-cmd --zone=internal --list-all
```

**Evidencia esperada:**
```
internal (active)
  target: default
  sources: 2025:db8:101::/64
  interfaces: ens34
  services: dhcpv6 dhcpv6-client ftp http https ssh
  rich rules:
    rule family="ipv6" source address="2025:db8:100::/64" accept
```

#### Servicios Permitidos
```bash
# Listar servicios permitidos
sudo firewall-cmd --zone=internal --list-services
```

**Evidencia esperada:**
```
dhcpv6 dhcpv6-client ftp http https ssh
```

### Zona External (Red Laboratorio - 2025:db8:100::/64)

#### Reglas de Zona External
```bash
# Ver todas las reglas de zona external
sudo firewall-cmd --zone=external --list-all
```

**Evidencia esperada:**
```
external (active)
  target: default
  sources: 2025:db8:100::/64
  interfaces: ens33
  services: dhcpv6-client ssh
  rich rules:
```

#### Servicios Permitidos
```bash
# Listar servicios permitidos
sudo firewall-cmd --zone=external --list-services
```

**Evidencia esperada:**
```
dhcpv6-client ssh
```

### Reglas Asimétricas

#### Verificar Reglas Rich
```bash
# Ver reglas rich en todas las zonas
sudo firewall-cmd --zone=internal --list-rich-rules
sudo firewall-cmd --zone=external --list-rich-rules
```

**Comportamiento esperado:**
- ✅ **2025:db8:100::/64 → 2025:db8:101::/64**: PERMITIDO (regla rich en internal)
- ❌ **2025:db8:101::/64 → 2025:db8:100::/64**: BLOQUEADO (nuevas conexiones)
- ✅ **Respuestas establecidas**: PERMITIDAS (stateful firewall)

### Pruebas de Conectividad

#### Desde Red Laboratorio (2025:db8:100::/64)
```bash
# Probar acceso desde laboratorio a Fernandez
ping6 -c 4 2025:db8:101::1
curl -6 http://[2025:db8:101::10]
ssh ansible@2025:db8:101::10
```

**Resultado esperado:** ✅ PERMITIDO

#### Desde Red Fernandez (2025:db8:101::/64)
```bash
# Probar acceso desde Fernandez a laboratorio (nuevas conexiones)
ping6 -c 4 2025:db8:100::1
curl -6 http://[2025:db8:100::10]
```

**Resultado esperado:** ❌ BLOQUEADO (timeout o connection refused)

---

## 📊 AUDITORÍA Y MONITOREO

### Auditd

#### Estado de Auditd
```bash
# Verificar auditd
sudo systemctl status auditd --no-pager
sudo auditctl -l
```

#### Reglas de Auditoría
```bash
# Ver reglas configuradas
sudo cat /etc/audit/rules.d/99-hardening.rules
```

**Evidencia esperada:**
```
-w /etc/passwd -p wa -k identity
-w /etc/group -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/sudoers -p wa -k identity
-w /etc/ssh/sshd_config -p wa -k sshd
-w /var/log/auth.log -p wa -k auth
```

#### Buscar Eventos de Auditoría
```bash
# Buscar eventos por clave
sudo ausearch -k identity -i | tail -50
sudo ausearch -k sshd -i | tail -50
sudo ausearch -k auth -i | tail -50
```

#### Eventos de Modificación de Usuarios
```bash
# Ver cambios en archivos de usuarios
sudo ausearch -f /etc/passwd -i
sudo ausearch -f /etc/shadow -i
```

### Logs de Seguridad

#### Auth Log (Autenticación)
```bash
# Ver intentos de autenticación
sudo tail -100 /var/log/auth.log
sudo grep "Failed password" /var/log/auth.log | tail -20
sudo grep "Accepted publickey" /var/log/auth.log | tail -20
```

#### Syslog (Sistema)
```bash
# Ver eventos del sistema
sudo tail -100 /var/log/syslog
sudo grep -i "security\|firewall\|ssh" /var/log/syslog | tail -50
```

#### Logs de Firewall
```bash
# Ver logs del firewall
sudo journalctl -u firewalld --no-pager -n 100
sudo dmesg | grep -i "firewall\|drop\|reject" | tail -50
```

### Herramientas de Monitoreo

#### Procesos y Recursos
```bash
# Monitoreo en tiempo real
htop
iotop
nethogs
```

#### Conexiones Activas
```bash
# Ver conexiones SSH activas
sudo lsof -i :22
sudo netstat -tnpa | grep :22
sudo ss -tnpa | grep :22
```

#### Usuarios Conectados
```bash
# Ver usuarios activos
who
w
last | head -20
lastlog
```

---

## 🔍 COMANDOS DE VERIFICACIÓN

### Script de Verificación Completa
```bash
#!/bin/bash
# Script de verificación de seguridad

echo "╔════════════════════════════════════════════════════════════╗"
echo "║          VERIFICACIÓN DE SEGURIDAD LOCAL BÁSICA            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

echo "=== 1. HARDENING DEL SISTEMA ==="
echo "--- Kernel Hardening ---"
sudo sysctl -a | grep -E "net.ipv4|net.ipv6|kernel|fs" | grep -E "forward|redirect|source_route|log_martians|syncookies|dmesg_restrict|kptr_restrict|ptrace_scope|protected"
echo ""

echo "--- Usuarios y Permisos ---"
id operator
sudo -l -U operator 2>/dev/null | head -10
echo ""

echo "--- Servicios Deshabilitados ---"
systemctl list-unit-files | grep -E "avahi|cups|bluetooth"
echo ""

echo "=== 2. HARDENING SSH ==="
echo "--- Configuración SSH ---"
sudo grep -E "PermitRootLogin|PasswordAuthentication|MaxAuthTries|AllowUsers" /etc/ssh/sshd_config | grep -v "^#"
echo ""

echo "--- Estado SSH ---"
sudo systemctl is-active ssh
sudo sshd -t && echo "SSH config: OK" || echo "SSH config: ERROR"
echo ""

echo "--- Fail2ban ---"
sudo systemctl is-active fail2ban
sudo fail2ban-client status sshd 2>/dev/null | head -10
echo ""

echo "=== 3. FIREWALL ==="
echo "--- Estado ---"
sudo firewall-cmd --state
echo ""

echo "--- Zonas Activas ---"
sudo firewall-cmd --get-active-zones
echo ""

echo "--- Zona Internal ---"
sudo firewall-cmd --zone=internal --list-services
echo ""

echo "--- Zona External ---"
sudo firewall-cmd --zone=external --list-services
echo ""

echo "=== 4. AUDITORÍA ==="
echo "--- Auditd ---"
sudo systemctl is-active auditd
sudo auditctl -l | head -10
echo ""

echo "--- Últimos Eventos de Autenticación ---"
sudo tail -10 /var/log/auth.log
echo ""

echo "╔════════════════════════════════════════════════════════════╗"
echo "║                  VERIFICACIÓN COMPLETADA                   ║"
echo "╚════════════════════════════════════════════════════════════╝"
```

### Guardar como Script
```bash
# Crear script
sudo nano /usr/local/bin/verify_security.sh

# Dar permisos de ejecución
sudo chmod +x /usr/local/bin/verify_security.sh

# Ejecutar
sudo /usr/local/bin/verify_security.sh
```

---

## 📈 INTERPRETACIÓN DE RESULTADOS

### Indicadores de Seguridad Correcta

#### ✅ Hardening del Sistema
- [ ] Kernel hardening configurado (sysctl)
- [ ] Usuario operator con permisos limitados
- [ ] Servicios innecesarios deshabilitados
- [ ] Umask seguro (027)
- [ ] Límites de recursos configurados
- [ ] Auditd activo y configurado

#### ✅ Hardening SSH
- [ ] PermitRootLogin = no
- [ ] PasswordAuthentication = no
- [ ] PubkeyAuthentication = yes
- [ ] MaxAuthTries = 3
- [ ] Algoritmos seguros configurados
- [ ] Banner de advertencia activo
- [ ] Fail2ban activo y monitoreando SSH

#### ✅ Firewall
- [ ] Firewalld activo (running)
- [ ] Zonas internal y external configuradas
- [ ] Reglas asimétricas funcionando
- [ ] Servicios correctamente asignados por zona
- [ ] IPv6 forwarding controlado

#### ✅ Auditoría
- [ ] Auditd monitoreando archivos críticos
- [ ] Logs de autenticación activos
- [ ] Eventos registrados correctamente
- [ ] Herramientas de monitoreo disponibles

### Problemas Comunes y Soluciones

#### Problema: SSH no permite conexión
**Causa:** PasswordAuthentication deshabilitado sin clave pública
**Solución:**
```bash
# Copiar clave pública al servidor
ssh-copy-id ansible@<IP_SERVIDOR>
```

#### Problema: Firewall bloquea todo el tráfico
**Causa:** Zonas mal configuradas
**Solución:**
```bash
# Verificar y reconfigurar zonas
sudo firewall-cmd --get-active-zones
sudo firewall-cmd --zone=internal --add-source=2025:db8:101::/64 --permanent
sudo firewall-cmd --reload
```

#### Problema: Auditd no registra eventos
**Causa:** Servicio no iniciado o reglas no cargadas
**Solución:**
```bash
# Reiniciar auditd
sudo systemctl restart auditd
sudo auditctl -l  # Verificar reglas
```

---

## 📝 NOTAS IMPORTANTES

### Consideraciones de Seguridad

1. **Acceso SSH**: Solo mediante clave pública, sin contraseñas
2. **Usuario Root**: Acceso directo deshabilitado
3. **Firewall**: Reglas asimétricas entre redes
4. **Auditoría**: Todos los eventos críticos registrados
5. **Monitoreo**: Fail2ban protege contra ataques de fuerza bruta

### Mantenimiento

1. **Revisar logs regularmente**:
   ```bash
   sudo tail -f /var/log/auth.log
   sudo fail2ban-client status sshd
   ```

2. **Actualizar reglas de firewall según necesidad**:
   ```bash
   sudo firewall-cmd --zone=internal --add-service=<servicio> --permanent
   sudo firewall-cmd --reload
   ```

3. **Monitorear eventos de auditoría**:
   ```bash
   sudo ausearch -k identity -i | tail -50
   ```

### Nivel de Seguridad Alcanzado

🎯 **Nivel: ⭐⭐⭐⭐⭐**
- Hardening completo del sistema
- SSH configurado con mejores prácticas
- Firewall con políticas asimétricas
- Auditoría y monitoreo activos
- Protección contra ataques comunes

---

**Fecha de creación:** {{ ansible_date_time.iso8601 }}  
**Sistema:** Debian 12 Router  
**Proyecto:** VMWARE-101001

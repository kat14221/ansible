# 🚀 Guía Rápida: Levantar Proyecto y Generar Evidencias

## 📋 Objetivo

Esta guía te ayudará a:
1. ✅ Levantar el proyecto completo
2. ✅ Generar todas las evidencias automáticamente
3. ✅ Tomar capturas de pantalla
4. ✅ Demostrar cumplimiento de "Administración de usuarios, permisos y políticas"

**Tiempo estimado:** 30-45 minutos

---

## 🎯 Paso 1: Verificar Requisitos Previos

### 1.1 Verificar que Ansible está instalado

```bash
ansible --version
```

**Resultado esperado:** Ansible 2.9 o superior

### 1.2 Verificar conectividad a los hosts

```bash
cd /d/ansible
ansible -i inventory/hosts.yml all -m ping
```

**Resultado esperado:** Todos los hosts responden con "pong"

Si algún host falla, verifica:
- Las IPs en `inventory/hosts.yml`
- Que las VMs estén encendidas
- Que el usuario ansible tenga acceso SSH

---

## 🚀 Paso 2: Aplicar Configuración Completa

### 2.1 Crear usuarios académicos

```bash
ansible-playbook playbooks/configure_academic_lab.yml \
  -i inventory/hosts.yml \
  --tags users \
  -v
```

**Qué hace:**
- Crea grupos: alumnos, profesores
- Crea usuarios: alumno1-3, profesor1-2, admin
- Asigna permisos diferenciados

**Tiempo:** ~5 minutos

### 2.2 Aplicar hardening y configuración sudo

```bash
ansible-playbook playbooks/site.yml \
  -i inventory/hosts.yml \
  --tags hardening \
  -v
```

**Qué hace:**
- Crea usuario operator con permisos limitados
- Configura sudoers para operator y ansible
- Aplica hardening del kernel
- Configura límites de recursos

**Tiempo:** ~5 minutos

### 2.3 Aplicar SSH hardening

```bash
ansible-playbook playbooks/site.yml \
  -i inventory/hosts.yml \
  --tags ssh \
  -v
```

**Qué hace:**
- Configura SSH con políticas restrictivas
- Instala y configura fail2ban
- Establece algoritmos de cifrado seguros

**Tiempo:** ~3 minutos

### 2.4 Aplicar políticas de firewall

```bash
ansible-playbook playbooks/site.yml \
  -i inventory/hosts.yml \
  --tags firewall \
  -v
```

**Qué hace:**
- Configura firewalld con zonas
- Implementa reglas asimétricas
- Establece políticas de red

**Tiempo:** ~3 minutos

---

## 📊 Paso 3: Generar Evidencias Automáticamente

### 3.1 Opción A: Usar Playbook de Ansible (Recomendado)

```bash
ansible-playbook playbooks/generar_evidencias_usuarios.yml \
  -i inventory/hosts.yml \
  -v
```

**Resultado:** Genera todos los archivos de evidencias en `evidence/usuarios_permisos/reports/`

### 3.2 Opción B: Usar Script Bash

```bash
chmod +x scripts/generar_evidencias_usuarios.sh
./scripts/generar_evidencias_usuarios.sh
```

**Resultado:** Mismo que la opción A

### 3.3 Verificar evidencias generadas

```bash
ls -la evidence/usuarios_permisos/reports/
```

**Deberías ver:**
```
00_REPORTE_COMPLETO.txt
01_usuarios_sistema.txt
02_grupos_sistema.txt
03_sudoers_operator.txt
03_sudoers_ansible.txt
04_ssh_config.txt
04_ssh_algorithms.txt
05_fail2ban.txt
06_firewall.txt
07_kernel_hardening.txt
08_resource_limits.txt
09_auditoria.txt
```

---

## 📸 Paso 4: Tomar Capturas de Pantalla

### 4.1 Preparar directorio de capturas

```bash
mkdir -p evidence/usuarios_permisos/screenshots/{01_usuarios,02_sudo,03_ssh,04_firewall,05_hardening,06_auditoria}
```

### 4.2 Capturas de Usuarios (Sección 1)

**Conectarse al debian-router:**
```bash
ssh ansible@172.17.25.126
```

**Comando 1: Ver usuarios**
```bash
getent passwd | grep -E "(alumno|profesor|admin|operator)"
```
📸 **Captura:** `01_usuarios/getent_passwd.png`

**Comando 2: Ver grupos**
```bash
getent group | grep -E "(alumnos|profesores|sudo)"
```
📸 **Captura:** `01_usuarios/getent_group.png`

**Comando 3: Login como alumno**
```bash
# Abrir nueva terminal
ssh alumno1@2025:db8:101::10
# Password: alumno123
```
📸 **Captura:** `01_usuarios/login_alumno.png`

**Comando 4: Probar sudo (debe fallar)**
```bash
sudo ls
```
📸 **Captura:** `01_usuarios/sudo_denied_alumno.png`

### 4.3 Capturas de Sudo (Sección 2)

**Comando 1: Ver sudoers operator**
```bash
sudo cat /etc/sudoers.d/operator
```
📸 **Captura:** `02_sudo/sudoers_operator.png`

**Comando 2: Login como operator y probar comando permitido**
```bash
# Nueva terminal
ssh operator@172.17.25.126
sudo systemctl status apache2
```
📸 **Captura:** `02_sudo/operator_allowed.png`

**Comando 3: Probar comando NO permitido**
```bash
sudo apt install htop
```
📸 **Captura:** `02_sudo/operator_denied.png`

### 4.4 Capturas de SSH (Sección 3)

**Comando 1: Ver configuración SSH**
```bash
sudo grep -E "^(PermitRootLogin|PasswordAuthentication|MaxAuthTries)" /etc/ssh/sshd_config
```
📸 **Captura:** `03_ssh/ssh_config.png`

**Comando 2: Ver fail2ban**
```bash
sudo fail2ban-client status sshd
```
📸 **Captura:** `03_ssh/fail2ban_status.png`

**Comando 3: Intentar login como root (debe fallar)**
```bash
# Nueva terminal
ssh root@172.17.25.126
```
📸 **Captura:** `03_ssh/root_login_denied.png`

### 4.5 Capturas de Firewall (Sección 4)

**Comando 1: Ver zonas activas**
```bash
sudo firewall-cmd --get-active-zones
```
📸 **Captura:** `04_firewall/firewall_zones.png`

**Comando 2: Ver reglas zona internal**
```bash
sudo firewall-cmd --zone=internal --list-all
```
📸 **Captura:** `04_firewall/internal_rules.png`

**Comando 3: Ver reglas zona external**
```bash
sudo firewall-cmd --zone=external --list-all
```
📸 **Captura:** `04_firewall/external_rules.png`

**Comando 4: Ping desde 100::/64 a 101::/64 (debe funcionar)**
```bash
# Desde un host en red 100::/64
ping6 -c 4 2025:db8:101::10
```
📸 **Captura:** `04_firewall/ping_100_to_101.png`

**Comando 5: Ping desde 101::/64 a 100::/64 (debe fallar)**
```bash
# Desde ubuntu-pc (101::10)
ping6 -c 4 2025:db8:100::2
```
📸 **Captura:** `04_firewall/ping_101_to_100_denied.png`

### 4.6 Capturas de Hardening (Sección 5)

**Comando 1: Ver parámetros sysctl**
```bash
sudo sysctl -a | grep -E "(ip_forward|accept_redirects|syncookies)"
```
📸 **Captura:** `05_hardening/sysctl_params.png`

**Comando 2: Ver límites de recursos**
```bash
sudo cat /etc/security/limits.d/99-hardening.conf
```
📸 **Captura:** `05_hardening/resource_limits.png`

**Comando 3: Ver umask**
```bash
umask
```
📸 **Captura:** `05_hardening/umask.png`

### 4.7 Capturas de Auditoría (Sección 6)

**Comando 1: Ver estado auditd**
```bash
sudo systemctl status auditd
```
📸 **Captura:** `06_auditoria/auditd_status.png`

**Comando 2: Ver reglas de auditoría**
```bash
sudo cat /etc/audit/rules.d/99-hardening.rules
```
📸 **Captura:** `06_auditoria/audit_rules.png`

**Comando 3: Ver logs de autenticación**
```bash
sudo tail -20 /var/log/auth.log
```
📸 **Captura:** `06_auditoria/auth_logs.png`

---

## 📝 Paso 5: Crear Documento de Presentación

### 5.1 Revisar el reporte completo

```bash
cat evidence/usuarios_permisos/reports/00_REPORTE_COMPLETO.txt
```

### 5.2 Organizar evidencias

```bash
# Verificar que tienes todas las capturas
ls -R evidence/usuarios_permisos/screenshots/
```

### 5.3 Crear presentación

Usa el documento `docs/EVIDENCIAS_USUARIOS_PERMISOS.md` como guía para crear tu presentación.

**Estructura sugerida:**
1. Portada con título del proyecto
2. Introducción (qué se implementó)
3. Sección por cada tipo de evidencia (usuarios, sudo, SSH, firewall, hardening, auditoría)
4. Cada sección con:
   - Explicación de qué se hizo
   - Por qué es importante
   - Cómo ayuda a la administración
   - Capturas de pantalla
5. Matriz de cumplimiento
6. Conclusión

---

## ✅ Checklist Final

Antes de entregar, verifica que tienes:

### Evidencias Textuales
- [ ] Reporte completo generado
- [ ] 10+ archivos de evidencias individuales
- [ ] Todos los archivos tienen análisis y explicaciones

### Capturas de Pantalla
- [ ] 4+ capturas de usuarios
- [ ] 3+ capturas de sudo
- [ ] 3+ capturas de SSH
- [ ] 5+ capturas de firewall
- [ ] 3+ capturas de hardening
- [ ] 3+ capturas de auditoría

### Documentación
- [ ] Documento de evidencias completo
- [ ] Explicación de cada implementación
- [ ] Justificación de por qué ayuda a la administración
- [ ] Matriz de cumplimiento

### Validación
- [ ] Todos los usuarios funcionan correctamente
- [ ] Permisos sudo funcionan como se espera
- [ ] SSH hardening activo
- [ ] Firewall bloqueando correctamente
- [ ] Auditoría registrando eventos

---

## 🎯 Resumen de Comandos Rápidos

```bash
# 1. Aplicar toda la configuración
cd /d/ansible
ansible-playbook playbooks/configure_academic_lab.yml -i inventory/hosts.yml --tags users -v
ansible-playbook playbooks/site.yml -i inventory/hosts.yml --tags hardening,ssh,firewall -v

# 2. Generar evidencias
ansible-playbook playbooks/generar_evidencias_usuarios.yml -i inventory/hosts.yml -v

# 3. Ver reporte
cat evidence/usuarios_permisos/reports/00_REPORTE_COMPLETO.txt

# 4. Conectarse para capturas
ssh ansible@172.17.25.126
```

---

## 🏆 Nivel Alcanzado

**⭐⭐⭐⭐⭐ "Define políticas seguras con restricciones claras"**

Con estas evidencias demuestras:
✅ Gestión completa de usuarios por roles  
✅ Permisos diferenciados y granulares  
✅ Políticas de seguridad claras y documentadas  
✅ Restricciones específicas por tipo de usuario  
✅ Automatización completa  
✅ Auditoría y monitoreo  

---

**¡Éxito con tu proyecto!** 🚀

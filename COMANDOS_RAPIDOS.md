# ⚡ Comandos Rápidos - Evidencias de Usuarios y Permisos

## 🚀 Ejecución Rápida (5 minutos)

```bash
# 1. Ir al directorio del proyecto
cd /d/ansible

# 2. Aplicar toda la configuración
ansible-playbook playbooks/configure_academic_lab.yml -i inventory/hosts.yml --tags users -v
ansible-playbook playbooks/site.yml -i inventory/hosts.yml --tags hardening,ssh,firewall -v

# 3. Generar evidencias automáticamente
ansible-playbook playbooks/generar_evidencias_usuarios.yml -i inventory/hosts.yml -v

# 4. Ver reporte completo
cat evidence/usuarios_permisos/reports/00_REPORTE_COMPLETO.txt

# 5. Validar que todo está completo
chmod +x scripts/validar_evidencias.sh
./scripts/validar_evidencias.sh
```

---

## 📋 Comandos Detallados

### Paso 1: Verificar Requisitos

```bash
# Verificar Ansible
ansible --version

# Verificar conectividad
cd /d/ansible
ansible -i inventory/hosts.yml all -m ping
```

---

### Paso 2: Aplicar Configuración

#### 2.1 Crear Usuarios Académicos
```bash
ansible-playbook playbooks/configure_academic_lab.yml \
  -i inventory/hosts.yml \
  --tags users \
  -v
```

#### 2.2 Aplicar Hardening
```bash
ansible-playbook playbooks/site.yml \
  -i inventory/hosts.yml \
  --tags hardening \
  -v
```

#### 2.3 Aplicar SSH Hardening
```bash
ansible-playbook playbooks/site.yml \
  -i inventory/hosts.yml \
  --tags ssh \
  -v
```

#### 2.4 Aplicar Firewall
```bash
ansible-playbook playbooks/site.yml \
  -i inventory/hosts.yml \
  --tags firewall \
  -v
```

---

### Paso 3: Generar Evidencias

#### Opción A: Playbook Ansible (Recomendado)
```bash
ansible-playbook playbooks/generar_evidencias_usuarios.yml \
  -i inventory/hosts.yml \
  -v
```

#### Opción B: Script Bash
```bash
chmod +x scripts/generar_evidencias_usuarios.sh
./scripts/generar_evidencias_usuarios.sh
```

#### Opción C: Script PowerShell (Windows)
```powershell
.\scripts\generar_evidencias_usuarios.ps1
```

---

### Paso 4: Verificar Evidencias

```bash
# Ver reporte completo
cat evidence/usuarios_permisos/reports/00_REPORTE_COMPLETO.txt

# Listar todas las evidencias
ls -la evidence/usuarios_permisos/reports/

# Validar completitud
chmod +x scripts/validar_evidencias.sh
./scripts/validar_evidencias.sh
```

---

### Paso 5: Tomar Capturas

#### Conectarse al debian-router
```bash
ssh ansible@172.17.25.126
```

#### Capturas de Usuarios
```bash
# 1. Ver usuarios
getent passwd | grep -E "(alumno|profesor|admin|operator)"

# 2. Ver grupos
getent group | grep -E "(alumnos|profesores|sudo)"

# 3. Login como alumno (nueva terminal)
ssh alumno1@2025:db8:101::10
# Password: alumno123

# 4. Probar sudo (debe fallar)
sudo ls
```

#### Capturas de Sudo
```bash
# 1. Ver sudoers operator
sudo cat /etc/sudoers.d/operator

# 2. Login como operator (nueva terminal)
ssh operator@172.17.25.126

# 3. Comando permitido
sudo systemctl status apache2

# 4. Comando NO permitido
sudo apt install htop
```

#### Capturas de SSH
```bash
# 1. Ver configuración SSH
sudo grep -E "^(PermitRootLogin|PasswordAuthentication|MaxAuthTries)" /etc/ssh/sshd_config

# 2. Ver fail2ban
sudo fail2ban-client status sshd

# 3. Intentar login como root (nueva terminal - debe fallar)
ssh root@172.17.25.126
```

#### Capturas de Firewall
```bash
# 1. Ver zonas
sudo firewall-cmd --get-active-zones

# 2. Ver reglas internal
sudo firewall-cmd --zone=internal --list-all

# 3. Ver reglas external
sudo firewall-cmd --zone=external --list-all

# 4. Ping 100 → 101 (debe funcionar)
# Desde host en 100::/64
ping6 -c 4 2025:db8:101::10

# 5. Ping 101 → 100 (debe fallar)
# Desde ubuntu-pc
ping6 -c 4 2025:db8:100::2
```

#### Capturas de Hardening
```bash
# 1. Ver sysctl
sudo sysctl -a | grep -E "(ip_forward|accept_redirects|syncookies)"

# 2. Ver límites
sudo cat /etc/security/limits.d/99-hardening.conf

# 3. Ver umask
umask
```

#### Capturas de Auditoría
```bash
# 1. Ver auditd
sudo systemctl status auditd

# 2. Ver reglas
sudo cat /etc/audit/rules.d/99-hardening.rules

# 3. Ver logs
sudo tail -20 /var/log/auth.log
```

---

## 📸 Organizar Capturas

```bash
# Crear directorios
mkdir -p evidence/usuarios_permisos/screenshots/{01_usuarios,02_sudo,03_ssh,04_firewall,05_hardening,06_auditoria}

# Mover capturas a sus carpetas correspondientes
# (Hazlo manualmente según las capturas que tomaste)
```

---

## ✅ Validación Final

```bash
# Ejecutar validador
chmod +x scripts/validar_evidencias.sh
./scripts/validar_evidencias.sh

# Debe mostrar:
# ✓ Todas las verificaciones pasaron
# ✓ Estás listo para presentar las evidencias
```

---

## 📚 Documentación

```bash
# Leer guía completa
cat docs/EVIDENCIAS_USUARIOS_PERMISOS.md

# Leer guía rápida
cat docs/GUIA_RAPIDA_EVIDENCIAS.md

# Leer presentación
cat docs/PRESENTACION_EVIDENCIAS.md

# Ver resumen de archivos
cat docs/RESUMEN_ARCHIVOS_CREADOS.md
```

---

## 🎯 Checklist Rápido

- [ ] Aplicar configuración de usuarios
- [ ] Aplicar hardening
- [ ] Aplicar SSH hardening
- [ ] Aplicar firewall
- [ ] Generar evidencias
- [ ] Verificar reporte completo
- [ ] Tomar 20+ capturas
- [ ] Organizar capturas en carpetas
- [ ] Validar completitud
- [ ] Crear presentación

---

## 🏆 Resultado Esperado

Al finalizar tendrás:

✅ **12 archivos de evidencias textuales**  
✅ **20+ capturas de pantalla**  
✅ **Reporte completo consolidado**  
✅ **Documentación profesional**  
✅ **Nivel ⭐⭐⭐⭐⭐ alcanzado**  

---

## 🆘 Troubleshooting

### No puedo conectar a debian-router
```bash
# Verificar IP
ping 172.17.25.126

# Verificar SSH
ssh -v ansible@172.17.25.126

# Verificar que la VM está encendida
```

### Evidencias no se generan
```bash
# Verificar que los servicios están configurados
ssh ansible@172.17.25.126
sudo systemctl status auditd
sudo systemctl status fail2ban
sudo firewall-cmd --state
```

### Validador falla
```bash
# Ver qué falta
./scripts/validar_evidencias.sh

# Seguir las recomendaciones que muestra
```

---

**¡Éxito con tu proyecto!** 🚀

**Nivel alcanzado:** ⭐⭐⭐⭐⭐ "Define políticas seguras con restricciones claras"

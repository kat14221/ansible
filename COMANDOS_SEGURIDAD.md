# 🔒 COMANDOS RÁPIDOS - SEGURIDAD LOCAL BÁSICA

**Proyecto:** VMWARE-101001  
**Componente:** Seguridad Local Básica

---

## 🚀 GENERACIÓN DE EVIDENCIAS

### Generar todas las evidencias de seguridad
```bash
ansible-playbook playbooks/generar_evidencias_seguridad.yml -i inventory/hosts.yml
```

### Ver resumen general
```bash
cat evidence/seguridad/00_RESUMEN_SEGURIDAD.txt
```

---

## 🔍 VERIFICACIÓN RÁPIDA

### Hardening del Sistema
```bash
# Ver configuración de kernel
ssh ansible@172.17.25.126 "sudo sysctl -a | grep -E 'net.ipv4|net.ipv6|kernel|fs' | grep -E 'forward|redirect|syncookies|dmesg_restrict'"

# Ver usuario operator
ssh ansible@172.17.25.126 "id operator && sudo -l -U operator"

# Ver servicios deshabilitados
ssh ansible@172.17.25.126 "systemctl list-unit-files | grep -E 'avahi|cups|bluetooth'"
```

### SSH y Fail2ban
```bash
# Verificar configuración SSH
ssh ansible@172.17.25.126 "sudo sshd -t && echo 'SSH config: OK'"

# Ver configuración crítica de SSH
ssh ansible@172.17.25.126 "sudo grep -E 'PermitRootLogin|PasswordAuthentication|MaxAuthTries' /etc/ssh/sshd_config | grep -v '^#'"

# Estado de Fail2ban
ssh ansible@172.17.25.126 "sudo systemctl status fail2ban --no-pager"
ssh ansible@172.17.25.126 "sudo fail2ban-client status sshd"
```

### Firewall
```bash
# Estado del firewall
ssh ansible@172.17.25.126 "sudo firewall-cmd --state"

# Ver zonas activas
ssh ansible@172.17.25.126 "sudo firewall-cmd --get-active-zones"

# Ver reglas de zona internal
ssh ansible@172.17.25.126 "sudo firewall-cmd --zone=internal --list-all"

# Ver reglas de zona external
ssh ansible@172.17.25.126 "sudo firewall-cmd --zone=external --list-all"
```

### Auditoría
```bash
# Estado de auditd
ssh ansible@172.17.25.126 "sudo systemctl status auditd --no-pager"

# Ver reglas de auditoría
ssh ansible@172.17.25.126 "sudo auditctl -l"

# Buscar eventos de identidad
ssh ansible@172.17.25.126 "sudo ausearch -k identity -i | tail -20"
```

---

## 📊 MONITOREO EN TIEMPO REAL

### Logs de Autenticación
```bash
# Ver intentos de login en tiempo real
ssh ansible@172.17.25.126 "sudo tail -f /var/log/auth.log"

# Ver intentos fallidos
ssh ansible@172.17.25.126 "sudo grep 'Failed password' /var/log/auth.log | tail -20"

# Ver logins exitosos
ssh ansible@172.17.25.126 "sudo grep 'Accepted publickey' /var/log/auth.log | tail -20"
```

### Fail2ban
```bash
# Ver logs de fail2ban en tiempo real
ssh ansible@172.17.25.126 "sudo tail -f /var/log/fail2ban.log"

# Ver IPs baneadas
ssh ansible@172.17.25.126 "sudo fail2ban-client status sshd | grep 'Banned IP'"
```

### Firewall
```bash
# Ver logs del firewall
ssh ansible@172.17.25.126 "sudo journalctl -u firewalld -f"

# Ver paquetes bloqueados
ssh ansible@172.17.25.126 "sudo dmesg | grep -i 'drop\|reject' | tail -20"
```

### Conexiones Activas
```bash
# Ver usuarios conectados
ssh ansible@172.17.25.126 "who && w"

# Ver conexiones SSH activas
ssh ansible@172.17.25.126 "sudo ss -tnpa | grep :22"

# Ver últimos logins
ssh ansible@172.17.25.126 "last | head -20"
```

---

## 🔧 CONFIGURACIÓN Y MANTENIMIENTO

### Hardening del Sistema
```bash
# Recargar configuración de sysctl
ssh ansible@172.17.25.126 "sudo sysctl -p /etc/sysctl.d/99-hardening.conf"

# Ver límites de recursos
ssh ansible@172.17.25.126 "cat /etc/security/limits.d/99-hardening.conf"

# Verificar umask
ssh ansible@172.17.25.126 "umask"
```

### SSH
```bash
# Reiniciar SSH (cuidado!)
ssh ansible@172.17.25.126 "sudo systemctl restart ssh"

# Ver banner SSH
ssh ansible@172.17.25.126 "cat /etc/ssh/banner"

# Ver algoritmos de cifrado
ssh ansible@172.17.25.126 "sudo grep -E 'Ciphers|MACs|KexAlgorithms' /etc/ssh/sshd_config"
```

### Fail2ban
```bash
# Reiniciar fail2ban
ssh ansible@172.17.25.126 "sudo systemctl restart fail2ban"

# Desbanear una IP
ssh ansible@172.17.25.126 "sudo fail2ban-client set sshd unbanip <IP>"

# Ver configuración
ssh ansible@172.17.25.126 "cat /etc/fail2ban/jail.local"
```

### Firewall
```bash
# Recargar firewall
ssh ansible@172.17.25.126 "sudo firewall-cmd --reload"

# Agregar servicio a zona internal
ssh ansible@172.17.25.126 "sudo firewall-cmd --zone=internal --add-service=<servicio> --permanent && sudo firewall-cmd --reload"

# Agregar regla rich
ssh ansible@172.17.25.126 "sudo firewall-cmd --zone=internal --add-rich-rule='rule family=\"ipv6\" source address=\"<red>\" accept' --permanent && sudo firewall-cmd --reload"

# Ver configuración permanente
ssh ansible@172.17.25.126 "sudo firewall-cmd --permanent --zone=internal --list-all"
```

### Auditoría
```bash
# Reiniciar auditd
ssh ansible@172.17.25.126 "sudo systemctl restart auditd"

# Buscar eventos por archivo
ssh ansible@172.17.25.126 "sudo ausearch -f /etc/passwd -i"

# Buscar eventos por usuario
ssh ansible@172.17.25.126 "sudo ausearch -ua <usuario> -i"

# Ver estadísticas de auditoría
ssh ansible@172.17.25.126 "sudo aureport"
```

---

## 🧪 PRUEBAS DE SEGURIDAD

### Probar Reglas Asimétricas del Firewall

#### Desde Red Laboratorio (2025:db8:100::/64) → Fernandez (2025:db8:101::/64)
```bash
# Debe funcionar ✅
ping6 -c 4 2025:db8:101::1
curl -6 http://[2025:db8:101::10]
ssh ansible@2025:db8:101::10
```

#### Desde Red Fernandez (2025:db8:101::/64) → Laboratorio (2025:db8:100::/64)
```bash
# Debe fallar ❌ (nuevas conexiones bloqueadas)
ping6 -c 4 2025:db8:100::1
curl -6 http://[2025:db8:100::10]
```

### Probar Fail2ban
```bash
# Intentar login con contraseña incorrecta varias veces
# (desde otra máquina, no desde ansible@)
ssh usuario_falso@172.17.25.126

# Verificar que la IP fue baneada
ssh ansible@172.17.25.126 "sudo fail2ban-client status sshd"
```

### Probar SSH Hardening
```bash
# Intentar login como root (debe fallar)
ssh root@172.17.25.126

# Intentar con contraseña (debe fallar)
ssh -o PreferredAuthentications=password ansible@172.17.25.126
```

---

## 📋 SCRIPTS ÚTILES

### Script de Verificación Completa
```bash
# Crear script
cat > /tmp/verify_security.sh << 'EOF'
#!/bin/bash
echo "=== VERIFICACIÓN DE SEGURIDAD ==="
echo ""
echo "1. Kernel Hardening:"
sudo sysctl net.ipv4.tcp_syncookies kernel.dmesg_restrict
echo ""
echo "2. SSH:"
sudo systemctl is-active ssh
sudo sshd -t && echo "Config: OK" || echo "Config: ERROR"
echo ""
echo "3. Fail2ban:"
sudo systemctl is-active fail2ban
sudo fail2ban-client status sshd | head -5
echo ""
echo "4. Firewall:"
sudo firewall-cmd --state
sudo firewall-cmd --get-active-zones
echo ""
echo "5. Auditoría:"
sudo systemctl is-active auditd
sudo auditctl -l | wc -l | awk '{print $1 " reglas activas"}'
EOF

# Copiar y ejecutar en el servidor
scp /tmp/verify_security.sh ansible@172.17.25.126:/tmp/
ssh ansible@172.17.25.126 "chmod +x /tmp/verify_security.sh && /tmp/verify_security.sh"
```

---

## 📖 DOCUMENTACIÓN

### Ver documentación completa
```bash
cat docs/EVIDENCIAS_SEGURIDAD.md
```

### Ver evidencias generadas
```bash
ls -lh evidence/seguridad/
cat evidence/seguridad/00_RESUMEN_SEGURIDAD.txt
```

---

## ⚠️ NOTAS IMPORTANTES

1. **SSH**: Solo acceso con clave pública, sin contraseñas
2. **Root**: Login directo deshabilitado
3. **Firewall**: Reglas asimétricas entre redes
4. **Fail2ban**: Protección automática contra ataques
5. **Auditoría**: Todos los eventos críticos registrados

---

**Última actualización:** 2024  
**Proyecto:** VMWARE-101001

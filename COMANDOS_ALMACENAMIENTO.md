# ⚡ Comandos Rápidos - Gestión de Almacenamiento

## 🚀 Ejecución Rápida (5 minutos)

```bash
# 1. Ir al directorio del proyecto
cd /d/ansible

# 2. Aplicar configuración de almacenamiento
ansible-playbook playbooks/configure_storage.yml -i inventory/hosts.yml -v

# 3. Verificar configuración
ssh ansible@172.17.25.126
df -h
sudo repquota -a

# 4. Ejecutar análisis
sudo /usr/local/bin/analyze_disk_usage.sh
```

---

## 📋 Comandos de Verificación

### Estructura de Particiones

```bash
# Ver particiones
lsblk -f

# Ver tabla de particiones
sudo fdisk -l /dev/sda

# Ver uso de espacio
df -h

# Ver uso de inodos
df -i
```

---

### Sistemas de Archivos

```bash
# Ver sistemas montados
mount | grep "^/dev"

# Ver configuración de montaje
cat /etc/fstab

# Ver opciones de montaje activas
findmnt
```

---

### Gestión de Espacio

```bash
# Uso por directorio (top level)
sudo du -sh /* 2>/dev/null | sort -h

# Uso detallado de un directorio
sudo du -h /var | sort -h | tail -20

# Árbol de directorios
tree -L 2 -d /srv

# Análisis interactivo
sudo ncdu /
```

---

### Cuotas de Disco

```bash
# Ver cuotas de usuarios
sudo repquota -a

# Ver cuotas de grupos
sudo repquota -g /

# Ver cuota de un usuario específico
sudo quota -u alumno1

# Configurar cuota para un usuario
sudo setquota -u alumno1 500M 600M 0 0 /
```

---

### Monitoreo

```bash
# Ver logs de monitoreo
sudo tail -f /var/log/storage/disk_monitor.log

# Ejecutar monitoreo manual
sudo /usr/local/bin/monitor_disk_space.sh

# Ver archivos grandes
find / -type f -size +100M -exec du -h {} \; 2>/dev/null | sort -h

# Análisis completo
sudo /usr/local/bin/analyze_disk_usage.sh
```

---

### Limpieza

```bash
# Ejecutar limpieza manual
sudo /usr/local/bin/cleanup_temp.sh

# Limpiar archivos temporales
sudo find /tmp -type f -mtime +7 -delete

# Limpiar cache de paquetes
sudo apt-get clean

# Comprimir logs antiguos
sudo find /var/log -name "*.log" -mtime +7 -exec gzip {} \;
```

---

### Backups

```bash
# Ver backups existentes
ls -lh /backup/configs/

# Verificar contenido de backup
sudo tar -tzf /backup/configs/config_backup_*.tar.gz | head -20

# Restaurar desde backup
sudo tar -xzf /backup/configs/config_backup_YYYYMMDD.tar.gz -C /
```

---

## 📸 Capturas Necesarias

### Captura 1: Estructura de particiones
```bash
lsblk -f
```
📸 **Guardar como:** `screenshots/01_particiones.png`

### Captura 2: Uso de espacio
```bash
df -h
```
📸 **Guardar como:** `screenshots/02_uso_espacio.png`

### Captura 3: Uso de inodos
```bash
df -i
```
📸 **Guardar como:** `screenshots/03_inodos.png`

### Captura 4: Sistemas de archivos
```bash
mount | grep "^/dev"
```
📸 **Guardar como:** `screenshots/04_sistemas_archivos.png`

### Captura 5: Estructura de directorios
```bash
tree -L 2 /srv
```
📸 **Guardar como:** `screenshots/05_estructura_directorios.png`

### Captura 6: Cuotas de usuarios
```bash
sudo repquota -a
```
📸 **Guardar como:** `screenshots/06_cuotas_usuarios.png`

### Captura 7: Cuotas de grupos
```bash
sudo repquota -g /
```
📸 **Guardar como:** `screenshots/07_cuotas_grupos.png`

### Captura 8: Análisis de espacio
```bash
sudo /usr/local/bin/analyze_disk_usage.sh
```
📸 **Guardar como:** `screenshots/08_analisis.png`

### Captura 9: Logs de monitoreo
```bash
sudo tail -30 /var/log/storage/disk_monitor.log
```
📸 **Guardar como:** `screenshots/09_logs_monitoreo.png`

### Captura 10: Backups
```bash
ls -lh /backup/configs/
```
📸 **Guardar como:** `screenshots/10_backups.png`

---

## ✅ Checklist de Evidencias

### Configuración
- [ ] Particiones organizadas
- [ ] Sistemas de archivos optimizados
- [ ] Directorios estructurados
- [ ] Permisos configurados

### Cuotas
- [ ] Cuotas habilitadas
- [ ] Cuotas por usuario
- [ ] Cuotas por grupo
- [ ] Límites apropiados

### Monitoreo
- [ ] Script de monitoreo creado
- [ ] Tarea cron configurada
- [ ] Logs generándose
- [ ] Alertas funcionando

### Limpieza
- [ ] Script de limpieza creado
- [ ] Limpieza automática programada
- [ ] Compresión de logs
- [ ] Espacio liberado

### Backups
- [ ] Backups automáticos
- [ ] Retención configurada
- [ ] Integridad verificada
- [ ] Restauración probada

---

## 🎯 Qué Demuestras

### ✅ Organización
- Estructura de particiones lógica
- Directorios bien organizados
- Permisos apropiados
- Separación de datos

### ✅ Control
- Cuotas de disco implementadas
- Límites por usuario y grupo
- Prevención de llenado
- Distribución justa

### ✅ Monitoreo
- Verificación automática
- Alertas proactivas
- Identificación de problemas
- Logs detallados

### ✅ Optimización
- Limpieza automática
- Compresión de logs
- Uso eficiente de espacio
- Backups con retención

---

## 📊 Matriz de Cumplimiento

| Criterio | Implementado | Evidencia |
|----------|--------------|-----------|
| Particiones | ✅ | Organizadas |
| Sistemas de archivos | ✅ | Optimizados |
| Cuotas | ✅ | Configuradas |
| Monitoreo | ✅ | Automático |
| Limpieza | ✅ | Programada |
| Backups | ✅ | Diarios |

**NIVEL: ⭐⭐⭐⭐⭐**

---

**¡Éxito con tu gestión de almacenamiento!** 🚀

**Nivel alcanzado:** ⭐⭐⭐⭐⭐ "Administración avanzada, uso eficiente de espacio"

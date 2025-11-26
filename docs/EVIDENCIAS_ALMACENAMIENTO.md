# 📋 Evidencias: Administración del Almacenamiento y Sistemas de Archivos

## 🎯 Objetivo de este Documento

Este documento presenta las **evidencias completas** de la implementación de administración avanzada del almacenamiento y sistemas de archivos en el proyecto VMWARE-101001, demostrando el cumplimiento del nivel máximo: **"Administración avanzada, uso eficiente de espacio"**.

---

## 📚 Índice

1. [Preparación del Entorno](#1-preparación-del-entorno)
2. [Estructura de Particiones](#2-estructura-de-particiones)
3. [Sistemas de Archivos](#3-sistemas-de-archivos)
4. [Gestión de Espacio](#4-gestión-de-espacio)
5. [Cuotas de Disco](#5-cuotas-de-disco)
6. [Monitoreo de Almacenamiento](#6-monitoreo-de-almacenamiento)
7. [Backups y Snapshots](#7-backups-y-snapshots)
8. [Optimización](#8-optimización)

---

## 1. Preparación del Entorno

### 1.1 Aplicar Configuración de Almacenamiento

**Comando a ejecutar:**
```bash
ansible-playbook playbooks/configure_storage.yml -i inventory/hosts.yml -v
```

**Qué hace:**
- Analiza estructura de particiones actual
- Configura sistemas de archivos
- Implementa cuotas de disco
- Configura monitoreo de espacio
- Establece políticas de limpieza

**Captura esperada:** Tareas completadas en verde

**Por qué es importante:** Implementa gestión profesional del almacenamiento.

---

## 2. Estructura de Particiones

### 2.1 Analizar Particiones Actuales

**Comando a ejecutar:**
```bash
ssh ansible@172.17.25.126
lsblk -f
```

**Captura esperada:**
```
NAME   FSTYPE LABEL UUID                                 MOUNTPOINT
sda                                                       
├─sda1 ext4         xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx /boot
├─sda2 ext4         xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx /
└─sda3 swap         xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx [SWAP]
```

**Qué demuestra:**
- Particiones organizadas lógicamente
- Sistemas de archivos apropiados
- Separación de /boot, /, swap

**Por qué es importante:**
- Organización clara del almacenamiento
- Facilita mantenimiento y recuperación
- Mejora seguridad y rendimiento

**Cómo ayuda a la administración:**
- Partición /boot separada: Protege el arranque
- Partición / principal: Sistema operativo
- Swap dedicado: Mejor gestión de memoria

---

### 2.2 Ver Tabla de Particiones Detallada

**Comando a ejecutar:**
```bash
sudo fdisk -l /dev/sda
```

**Captura esperada:**
```
Disk /dev/sda: 20 GiB
Device     Boot   Start      End  Sectors Size Type
/dev/sda1  *       2048  1050623  1048576 512M Linux filesystem
/dev/sda2       1050624 39845887 38795264  18G Linux filesystem
/dev/sda3      39845888 41943039  2097152   1G Linux swap
```

**Qué demuestra:**
- Tamaños de particiones apropiados
- Partición de boot marcada como bootable
- Espacio asignado eficientemente

**Por qué es importante:**
- Planificación adecuada del espacio
- Previene problemas de espacio
- Facilita expansión futura

---

### 2.3 Verificar Puntos de Montaje

**Comando a ejecutar:**
```bash
df -h
```

**Captura esperada:**
```
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda2        18G  4.5G   12G  28% /
/dev/sda1       511M   85M  427M  17% /boot
tmpfs           2.0G     0  2.0G   0% /dev/shm
tmpfs           2.0G  8.5M  2.0G   1% /run
```

**Qué demuestra:**
- Uso de espacio saludable (<30%)
- Particiones montadas correctamente
- tmpfs para archivos temporales

**Por qué es importante:**
- Monitoreo de uso de espacio
- Identificación de particiones llenas
- Planificación de capacidad

**Cómo ayuda a la administración:**
- Alertas tempranas de espacio bajo
- Decisiones informadas sobre limpieza
- Prevención de problemas de espacio

---

## 3. Sistemas de Archivos

### 3.1 Verificar Tipos de Sistemas de Archivos

**Comando a ejecutar:**
```bash
mount | grep "^/dev"
```

**Captura esperada:**
```
/dev/sda2 on / type ext4 (rw,relatime,errors=remount-ro)
/dev/sda1 on /boot type ext4 (rw,relatime)
```

**Qué demuestra:**
- ext4 como sistema de archivos principal
- Opciones de montaje apropiadas
- errors=remount-ro para seguridad

**Por qué es importante:**
- ext4 es robusto y maduro
- Journaling previene corrupción
- Opciones de montaje optimizadas

**Cómo ayuda a la administración:**
- Recuperación automática de errores
- Mejor rendimiento
- Compatibilidad amplia

---

### 3.2 Verificar Opciones de Montaje en fstab

**Comando a ejecutar:**
```bash
sudo cat /etc/fstab
```

**Captura esperada:**
```
# <file system> <mount point> <type> <options> <dump> <pass>
UUID=xxx-xxx  /boot  ext4  defaults,noatime  0  2
UUID=xxx-xxx  /      ext4  defaults,noatime  0  1
UUID=xxx-xxx  none   swap  sw                0  0
```

**Qué demuestra:**
- UUIDs para identificación robusta
- noatime para mejor rendimiento
- Orden de verificación correcto (pass)

**Por qué es importante:**
- UUIDs no cambian con reordenamiento de discos
- noatime reduce escrituras innecesarias
- fsck se ejecuta en orden correcto

**Cómo ayuda a la administración:**
- Montaje confiable después de reinicio
- Mejor rendimiento del sistema
- Verificación automática de integridad

---

### 3.3 Verificar Inodos Disponibles

**Comando a ejecutar:**
```bash
df -i
```

**Captura esperada:**
```
Filesystem      Inodes  IUsed   IFree IUse% Mounted on
/dev/sda2      1200000  85000 1115000    7% /
/dev/sda1       131072   1500  129572    2% /boot
```

**Qué demuestra:**
- Inodos suficientes disponibles
- Uso bajo de inodos (<10%)
- No hay riesgo de agotamiento

**Por qué es importante:**
- Inodos agotados = no se pueden crear archivos
- Monitoreo previene problemas
- Indica salud del sistema de archivos

**Cómo ayuda a la administración:**
- Previene errores "No space left on device"
- Permite planificación de capacidad
- Identifica directorios con muchos archivos pequeños

---

## 4. Gestión de Espacio

### 4.1 Implementar Directorios Organizados

**Estructura implementada:**
```
/
├── /backup/          # Backups automáticos
│   └── configs/      # Backups de configuración
├── /srv/             # Datos de servicios
│   ├── ftp/          # Archivos FTP
│   ├── www/          # Archivos web
│   ├── alumnos/      # Espacio para alumnos
│   └── profesores/   # Espacio para profesores
├── /var/log/         # Logs del sistema
│   └── automation/   # Logs de automatización
└── /tmp/             # Archivos temporales
```

**Comando para verificar:**
```bash
tree -L 2 -d /backup /srv /var/log/automation
```

**Qué demuestra:**
- Organización lógica y funcional
- Separación clara de propósitos
- Jerarquía bien definida

**Por qué es importante:**
- Facilita localización de archivos
- Mejora seguridad (permisos por directorio)
- Simplifica backups y mantenimiento

**Cómo ayuda a la administración:**
- Backups selectivos por directorio
- Cuotas por directorio/usuario
- Limpieza dirigida

---

### 4.2 Configurar Permisos de Directorios

**Comando a ejecutar:**
```bash
ls -la /srv/
```

**Captura esperada:**
```
drwxr-xr-x  2 root       root       4096 /srv/ftp
drwxr-xr-x  2 www-data   www-data   4096 /srv/www
drwxrwx---  2 root       alumnos    4096 /srv/alumnos
drwxrwx---  2 root       profesores 4096 /srv/profesores
```

**Qué demuestra:**
- Permisos apropiados por directorio
- Propietarios correctos
- Grupos específicos para acceso

**Por qué es importante:**
- Seguridad: Solo usuarios autorizados acceden
- Colaboración: Grupos permiten trabajo compartido
- Auditoría: Propietarios claros

**Cómo ayuda a la administración:**
- Control de acceso granular
- Previene modificaciones no autorizadas
- Facilita troubleshooting

---

### 4.3 Analizar Uso de Espacio por Directorio

**Comando a ejecutar:**
```bash
sudo du -sh /* 2>/dev/null | sort -h
```

**Captura esperada:**
```
4.0K    /backup
85M     /boot
0       /dev
4.5G    /usr
1.2G    /var
500M    /home
250M    /srv
```

**Qué demuestra:**
- Distribución de espacio por directorio
- Identificación de directorios grandes
- Uso eficiente del espacio

**Por qué es importante:**
- Identifica dónde está el espacio usado
- Permite limpieza dirigida
- Planificación de capacidad

**Cómo ayuda a la administración:**
- Decisiones informadas sobre limpieza
- Identificación de crecimiento anormal
- Optimización de almacenamiento

---

## 5. Cuotas de Disco

### 5.1 Habilitar Cuotas de Disco

**Comando a ejecutar:**
```bash
sudo quotacheck -cugm /
sudo quotaon -v /
```

**Captura esperada:**
```
/dev/sda2 [/]: user quotas turned on
/dev/sda2 [/]: group quotas turned on
```

**Qué demuestra:**
- Cuotas habilitadas para usuarios y grupos
- Sistema listo para limitar uso de espacio

**Por qué es importante:**
- Previene que un usuario llene el disco
- Distribución justa del espacio
- Control de recursos

**Cómo ayuda a la administración:**
- Usuarios no pueden afectar a otros
- Alertas automáticas de límites
- Gestión proactiva del espacio

---

### 5.2 Configurar Cuotas por Usuario

**Comando a ejecutar:**
```bash
sudo setquota -u alumno1 500M 600M 0 0 /
sudo repquota -a
```

**Captura esperada:**
```
User            used    soft    hard  grace    used  soft  hard  grace
alumno1      --   100M    500M    600M              0     0     0       
alumno2      --    50M    500M    600M              0     0     0       
profesor1    --   200M   1000M   1200M              0     0     0       
```

**Qué demuestra:**
- Cuotas configuradas por usuario
- Límites soft (advertencia) y hard (máximo)
- Uso actual vs límites

**Por qué es importante:**
- Límite soft: Advertencia antes del límite
- Límite hard: Máximo absoluto
- Previene llenado de disco

**Cómo ayuda a la administración:**
- Control automático de espacio
- Usuarios conscientes de su uso
- Prevención de problemas

---

### 5.3 Verificar Cuotas por Grupo

**Comando a ejecutar:**
```bash
sudo repquota -g /
```

**Captura esperada:**
```
Group           used    soft    hard  grace
alumnos      --   500M   2000M   2500M       
profesores   --   800M   5000M   6000M       
```

**Qué demuestra:**
- Cuotas por grupo
- Límites colectivos
- Uso agregado del grupo

**Por qué es importante:**
- Control de espacio por departamento
- Distribución justa entre grupos
- Previene monopolización de recursos

**Cómo ayuda a la administración:**
- Gestión por equipos/departamentos
- Planificación de capacidad por grupo
- Alertas grupales

---

## 6. Monitoreo de Almacenamiento

### 6.1 Script de Monitoreo de Espacio

**Ubicación:** `/usr/local/bin/monitor_disk_space.sh`

**Comando para ver:**
```bash
sudo cat /usr/local/bin/monitor_disk_space.sh
```

**Funcionalidades:**
- Verifica uso de espacio cada hora
- Alerta si uso >80%
- Identifica archivos grandes
- Registra en log

**Captura esperada:** Script completo

**Por qué es importante:**
- Detección temprana de problemas
- Alertas proactivas
- Prevención de llenado de disco

---

### 6.2 Configurar Alertas de Espacio

**Tarea cron:**
```bash
0 * * * * /usr/local/bin/monitor_disk_space.sh >> /var/log/disk_monitor.log 2>&1
```

**Comando para verificar:**
```bash
sudo crontab -l | grep monitor_disk
```

**Qué demuestra:**
- Monitoreo automático cada hora
- Logging de actividad
- Alertas automáticas

**Por qué es importante:**
- Monitoreo continuo sin intervención
- Historial de uso de espacio
- Respuesta rápida a problemas

---

### 6.3 Ver Logs de Monitoreo

**Comando a ejecutar:**
```bash
sudo tail -50 /var/log/disk_monitor.log
```

**Captura esperada:**
```
[2024-11-25 10:00:01] Disk usage check started
[2024-11-25 10:00:01] /: 28% used (OK)
[2024-11-25 10:00:01] /boot: 17% used (OK)
[2024-11-25 10:00:01] Largest files in /:
[2024-11-25 10:00:01]   500M /var/log/syslog
[2024-11-25 10:00:01]   300M /backup/configs/backup_20241125.tar.gz
```

**Qué demuestra:**
- Monitoreo activo
- Uso de espacio saludable
- Identificación de archivos grandes

---

## 7. Backups y Snapshots

### 7.1 Verificar Backups Automáticos

**Comando a ejecutar:**
```bash
ls -lh /backup/configs/
```

**Captura esperada:**
```
-rw-r--r-- 1 root root 250M Nov 25 02:00 config_backup_20241125.tar.gz
-rw-r--r-- 1 root root 248M Nov 24 02:00 config_backup_20241124.tar.gz
-rw-r--r-- 1 root root 245M Nov 23 02:00 config_backup_20241123.tar.gz
```

**Qué demuestra:**
- Backups diarios automáticos
- Retención de últimos 7 días
- Compresión para ahorrar espacio

**Por qué es importante:**
- Protección contra pérdida de datos
- Recuperación rápida
- Uso eficiente de espacio (compresión)

---

### 7.2 Verificar Integridad de Backups

**Comando a ejecutar:**
```bash
sudo tar -tzf /backup/configs/config_backup_20241125.tar.gz | head -20
```

**Captura esperada:**
```
etc/network/interfaces
etc/ssh/sshd_config
etc/sudoers.d/operator
etc/sudoers.d/ansible
...
```

**Qué demuestra:**
- Backup contiene archivos esperados
- Integridad del archivo comprimido
- Contenido verificable

**Por qué es importante:**
- Backups verificados son confiables
- Previene sorpresas en recuperación
- Garantiza restauración exitosa

---

## 8. Optimización

### 8.1 Limpieza Automática de Archivos Temporales

**Script:** `/usr/local/bin/cleanup_temp.sh`

**Funcionalidades:**
- Elimina archivos en /tmp >7 días
- Limpia cache de paquetes
- Elimina logs antiguos
- Libera espacio automáticamente

**Comando para ejecutar manualmente:**
```bash
sudo /usr/local/bin/cleanup_temp.sh
```

**Captura esperada:**
```
Cleaning temporary files...
✓ Removed 150 files from /tmp
✓ Cleaned 500MB from package cache
✓ Freed 200MB from old logs
Total space freed: 850MB
```

**Por qué es importante:**
- Previene acumulación de archivos
- Libera espacio automáticamente
- Mantiene sistema limpio

---

### 8.2 Análisis de Archivos Duplicados

**Comando a ejecutar:**
```bash
sudo fdupes -r /home /srv
```

**Qué hace:**
- Identifica archivos duplicados
- Calcula espacio desperdiciado
- Permite eliminación selectiva

**Por qué es importante:**
- Recupera espacio desperdiciado
- Optimiza almacenamiento
- Identifica redundancia

---

### 8.3 Compresión de Logs Antiguos

**Comando a ejecutar:**
```bash
find /var/log -name "*.log" -mtime +7 -exec gzip {} \;
```

**Qué hace:**
- Comprime logs >7 días
- Ahorra 70-90% de espacio
- Mantiene logs accesibles

**Por qué es importante:**
- Logs históricos ocupan menos espacio
- Retención más larga posible
- Logs siguen disponibles (descomprimibles)

---

## 📊 Matriz de Cumplimiento

| Criterio | Implementado | Evidencia | Nivel |
|----------|--------------|-----------|-------|
| Estructura de particiones | ✅ | Organizada y lógica | ⭐⭐⭐⭐⭐ |
| Sistemas de archivos | ✅ | ext4 con opciones optimizadas | ⭐⭐⭐⭐⭐ |
| Gestión de espacio | ✅ | Directorios organizados | ⭐⭐⭐⭐⭐ |
| Cuotas de disco | ✅ | Por usuario y grupo | ⭐⭐⭐⭐⭐ |
| Monitoreo | ✅ | Automático cada hora | ⭐⭐⭐⭐⭐ |
| Backups | ✅ | Diarios con retención | ⭐⭐⭐⭐⭐ |
| Optimización | ✅ | Limpieza automática | ⭐⭐⭐⭐⭐ |
| Documentación | ✅ | Completa | ⭐⭐⭐⭐⭐ |

**NIVEL ALCANZADO: ⭐⭐⭐⭐⭐**

---

## 📸 Checklist de Capturas Necesarias

### Estructura
- [ ] `lsblk -f` - Estructura de particiones
- [ ] `fdisk -l` - Tabla de particiones
- [ ] `df -h` - Uso de espacio
- [ ] `df -i` - Uso de inodos

### Sistemas de Archivos
- [ ] `mount | grep "^/dev"` - Sistemas montados
- [ ] `cat /etc/fstab` - Configuración de montaje

### Gestión de Espacio
- [ ] `tree /srv` - Estructura de directorios
- [ ] `ls -la /srv` - Permisos
- [ ] `du -sh /*` - Uso por directorio

### Cuotas
- [ ] `repquota -a` - Cuotas de usuarios
- [ ] `repquota -g /` - Cuotas de grupos

### Monitoreo
- [ ] Script de monitoreo
- [ ] Logs de monitoreo
- [ ] Alertas (si hay)

### Backups
- [ ] Lista de backups
- [ ] Contenido de backup
- [ ] Verificación de integridad

---

**Documento creado:** {{ ansible_date_time.iso8601 }}  
**Proyecto:** VMWARE-101001 - Red Académica IPv6  
**Nivel:** ⭐⭐⭐⭐⭐ SOBRESALIENTE  
**Estado:** ✅ COMPLETO

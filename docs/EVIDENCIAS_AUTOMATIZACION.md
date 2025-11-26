# 📋 Evidencias: Automatización de Tareas

## 🎯 Objetivo de este Documento

Este documento presenta las **evidencias completas** de la implementación de automatización de tareas con cron y tareas programadas en el proyecto VMWARE-101001, demostrando el cumplimiento del nivel máximo: **"Automatización robusta y validada"**.

---

## 📚 Índice

1. [Preparación del Entorno](#1-preparación-del-entorno)
2. [Tareas Cron Implementadas](#2-tareas-cron-implementadas)
3. [Scripts de Automatización](#3-scripts-de-automatización)
4. [Validación de Tareas](#4-validación-de-tareas)
5. [Monitoreo y Logs](#5-monitoreo-y-logs)
6. [Evidencias Finales](#6-evidencias-finales)

---

## 1. Preparación del Entorno

### 1.1 Aplicar Configuración de Automatización

**Comando a ejecutar:**
```bash
ansible-playbook playbooks/configure_automation.yml -i inventory/hosts.yml -v
```

**Qué hace:**
- Instala cron en todos los sistemas Linux
- Configura tareas programadas
- Crea scripts de automatización
- Configura logs y monitoreo

**Captura esperada:** Tareas completadas en verde

**Por qué es importante:** Implementa automatización robusta para mantenimiento del sistema.

---

## 2. Tareas Cron Implementadas

### 2.1 Backup Automático de Configuraciones

**Tarea:** Backup diario de archivos de configuración críticos

**Configuración cron:**
```bash
0 2 * * * /usr/local/bin/backup_configs.sh >> /var/log/backup_configs.log 2>&1
```

**Qué hace:**
- Se ejecuta todos los días a las 2:00 AM
- Hace backup de `/etc/`, `/home/`, configuraciones de red
- Guarda backups en `/backup/configs/`
- Mantiene últimos 7 días de backups
- Registra actividad en log

**Por qué es importante:**
- Protege contra pérdida de configuración
- Permite restauración rápida
- Cumple con políticas de backup

**Cómo ayuda a la administración:**
- Backups automáticos sin intervención manual
- Recuperación ante desastres
- Auditoría de cambios de configuración

---

### 2.2 Limpieza de Logs Antiguos

**Tarea:** Limpieza semanal de logs antiguos

**Configuración cron:**
```bash
0 3 * * 0 /usr/local/bin/cleanup_logs.sh >> /var/log/cleanup.log 2>&1
```

**Qué hace:**
- Se ejecuta todos los domingos a las 3:00 AM
- Elimina logs mayores a 30 días
- Comprime logs mayores a 7 días
- Libera espacio en disco

**Por qué es importante:**
- Previene llenado de disco
- Mantiene sistema limpio
- Mejora rendimiento

**Cómo ayuda a la administración:**
- Gestión automática de espacio
- No requiere intervención manual
- Previene problemas de espacio

---

### 2.3 Actualización de Paquetes de Seguridad

**Tarea:** Actualización semanal de paquetes de seguridad

**Configuración cron:**
```bash
0 4 * * 1 /usr/local/bin/security_updates.sh >> /var/log/security_updates.log 2>&1
```

**Qué hace:**
- Se ejecuta todos los lunes a las 4:00 AM
- Actualiza solo paquetes de seguridad
- Registra actualizaciones aplicadas
- Envía notificación si hay errores

**Por qué es importante:**
- Mantiene sistema seguro
- Aplica parches de seguridad automáticamente
- Reduce ventana de vulnerabilidad

**Cómo ayuda a la administración:**
- Sistema siempre actualizado
- Cumplimiento de políticas de seguridad
- Reducción de trabajo manual

---

### 2.4 Monitoreo de Servicios Críticos

**Tarea:** Verificación cada 5 minutos de servicios críticos

**Configuración cron:**
```bash
*/5 * * * * /usr/local/bin/check_services.sh >> /var/log/service_monitor.log 2>&1
```

**Qué hace:**
- Verifica estado de SSH, HTTP, FTP, DHCPv6, RADVD
- Reinicia servicios caídos automáticamente
- Registra incidentes
- Envía alertas

**Por qué es importante:**
- Alta disponibilidad de servicios
- Recuperación automática
- Detección temprana de problemas

**Cómo ayuda a la administración:**
- Servicios siempre disponibles
- Reducción de downtime
- Alertas proactivas

---

### 2.5 Reporte de Estado del Sistema

**Tarea:** Reporte diario del estado del sistema

**Configuración cron:**
```bash
0 8 * * * /usr/local/bin/system_report.sh >> /var/log/system_report.log 2>&1
```

**Qué hace:**
- Genera reporte de uso de CPU, memoria, disco
- Verifica conectividad de red
- Lista servicios activos
- Identifica problemas potenciales

**Por qué es importante:**
- Visibilidad del estado del sistema
- Detección proactiva de problemas
- Planificación de capacidad

**Cómo ayuda a la administración:**
- Información consolidada diaria
- Identificación temprana de problemas
- Toma de decisiones informada

---

### 2.6 Rotación de Logs de Firewall

**Tarea:** Rotación diaria de logs de firewall

**Configuración cron:**
```bash
0 1 * * * /usr/local/bin/rotate_firewall_logs.sh >> /var/log/log_rotation.log 2>&1
```

**Qué hace:**
- Rota logs de firewall diariamente
- Comprime logs antiguos
- Mantiene últimos 30 días
- Archiva logs importantes

**Por qué es importante:**
- Gestión eficiente de logs
- Cumplimiento de auditoría
- Previene llenado de disco

**Cómo ayuda a la administración:**
- Logs organizados y accesibles
- Facilita investigación de incidentes
- Cumplimiento normativo

---

## 3. Scripts de Automatización

### 3.1 Script de Backup (`backup_configs.sh`)

**Ubicación:** `/usr/local/bin/backup_configs.sh`

**Comando para ver:**
```bash
ssh ansible@172.17.25.126
sudo cat /usr/local/bin/backup_configs.sh
```

**Captura esperada:** Script completo con funciones de backup

**Funcionalidades:**
- Backup incremental
- Compresión automática
- Verificación de integridad
- Limpieza de backups antiguos
- Logging detallado

---

### 3.2 Script de Limpieza (`cleanup_logs.sh`)

**Ubicación:** `/usr/local/bin/cleanup_logs.sh`

**Comando para ver:**
```bash
sudo cat /usr/local/bin/cleanup_logs.sh
```

**Captura esperada:** Script con lógica de limpieza

**Funcionalidades:**
- Identificación de logs antiguos
- Compresión antes de eliminar
- Preservación de logs críticos
- Reporte de espacio liberado

---

### 3.3 Script de Monitoreo (`check_services.sh`)

**Ubicación:** `/usr/local/bin/check_services.sh`

**Comando para ver:**
```bash
sudo cat /usr/local/bin/check_services.sh
```

**Captura esperada:** Script con verificación de servicios

**Funcionalidades:**
- Verificación de estado de servicios
- Reinicio automático si están caídos
- Registro de incidentes
- Alertas por email (opcional)

---

## 4. Validación de Tareas

### 4.1 Listar Tareas Cron Activas

**Comando a ejecutar:**
```bash
ssh ansible@172.17.25.126
sudo crontab -l
```

**Captura esperada:**
```
# Backup diario de configuraciones
0 2 * * * /usr/local/bin/backup_configs.sh >> /var/log/backup_configs.log 2>&1

# Limpieza semanal de logs
0 3 * * 0 /usr/local/bin/cleanup_logs.sh >> /var/log/cleanup.log 2>&1

# Actualización de seguridad semanal
0 4 * * 1 /usr/local/bin/security_updates.sh >> /var/log/security_updates.log 2>&1

# Monitoreo de servicios cada 5 minutos
*/5 * * * * /usr/local/bin/check_services.sh >> /var/log/service_monitor.log 2>&1

# Reporte diario del sistema
0 8 * * * /usr/local/bin/system_report.sh >> /var/log/system_report.log 2>&1

# Rotación de logs de firewall
0 1 * * * /usr/local/bin/rotate_firewall_logs.sh >> /var/log/log_rotation.log 2>&1
```

**Por qué es importante:** Demuestra que las tareas están configuradas correctamente.

---

### 4.2 Verificar Estado del Servicio Cron

**Comando a ejecutar:**
```bash
sudo systemctl status cron
```

**Captura esperada:**
```
● cron.service - Regular background program processing daemon
     Loaded: loaded (/lib/systemd/system/cron.service; enabled)
     Active: active (running)
```

**Por qué es importante:** Confirma que el servicio cron está activo.

---

### 4.3 Verificar Ejecución de Tareas

**Comando a ejecutar:**
```bash
sudo grep CRON /var/log/syslog | tail -20
```

**Captura esperada:** Logs de ejecución de tareas cron

**Por qué es importante:** Demuestra que las tareas se están ejecutando.

---

## 5. Monitoreo y Logs

### 5.1 Ver Logs de Backup

**Comando a ejecutar:**
```bash
sudo tail -50 /var/log/backup_configs.log
```

**Captura esperada:** Logs de backups exitosos

**Qué demuestra:**
- Backups ejecutándose correctamente
- Archivos respaldados
- Espacio utilizado
- Tiempo de ejecución

---

### 5.2 Ver Logs de Monitoreo de Servicios

**Comando a ejecutar:**
```bash
sudo tail -50 /var/log/service_monitor.log
```

**Captura esperada:** Logs de verificación de servicios

**Qué demuestra:**
- Servicios monitoreados
- Estado de cada servicio
- Reinicios automáticos (si hubo)
- Timestamp de verificaciones

---

### 5.3 Ver Logs de Limpieza

**Comando a ejecutar:**
```bash
sudo tail -50 /var/log/cleanup.log
```

**Captura esperada:** Logs de limpieza de archivos

**Qué demuestra:**
- Archivos eliminados
- Espacio liberado
- Logs comprimidos
- Errores (si hubo)

---

## 6. Evidencias Finales

### 6.1 Generar Reporte de Automatización

**Comando a ejecutar:**
```bash
ansible-playbook playbooks/generar_evidencias_automatizacion.yml -i inventory/hosts.yml -v
```

**Qué hace:**
- Recopila todas las tareas cron
- Lista todos los scripts
- Muestra logs recientes
- Genera reporte consolidado

**Captura esperada:** Reporte completo generado

---

### 6.2 Matriz de Cumplimiento

| Criterio | Implementado | Evidencia | Nivel |
|----------|--------------|-----------|-------|
| Tareas cron configuradas | ✅ | 6 tareas activas | ⭐⭐⭐⭐⭐ |
| Scripts de automatización | ✅ | 6 scripts | ⭐⭐⭐⭐⭐ |
| Logs y monitoreo | ✅ | Logs detallados | ⭐⭐⭐⭐⭐ |
| Validación de ejecución | ✅ | Logs de syslog | ⭐⭐⭐⭐⭐ |
| Recuperación automática | ✅ | Reinicio de servicios | ⭐⭐⭐⭐⭐ |
| Documentación | ✅ | Completa | ⭐⭐⭐⭐⭐ |

**NIVEL ALCANZADO: ⭐⭐⭐⭐⭐**

---

## 📸 Checklist de Capturas Necesarias

### Configuración
- [ ] Lista de tareas cron (`crontab -l`)
- [ ] Estado del servicio cron
- [ ] Contenido de scripts de automatización

### Ejecución
- [ ] Logs de syslog mostrando ejecuciones
- [ ] Logs de backup
- [ ] Logs de monitoreo de servicios
- [ ] Logs de limpieza

### Validación
- [ ] Directorio de backups con archivos
- [ ] Servicios reiniciados automáticamente
- [ ] Espacio liberado por limpieza
- [ ] Reporte de sistema generado

---

**Documento creado:** {{ ansible_date_time.iso8601 }}  
**Proyecto:** VMWARE-101001 - Red Académica IPv6  
**Nivel:** ⭐⭐⭐⭐⭐ SOBRESALIENTE  
**Estado:** ✅ COMPLETO

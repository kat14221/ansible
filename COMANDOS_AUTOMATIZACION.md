# ⚡ Comandos Rápidos - Automatización de Tareas

## 🚀 Ejecución Rápida (5 minutos)

```bash
# 1. Ir al directorio del proyecto
cd /d/ansible

# 2. Aplicar configuración de automatización
ansible-playbook playbooks/configure_automation.yml -i inventory/hosts.yml -v

# 3. Generar evidencias
ansible-playbook playbooks/generar_evidencias_automatizacion.yml -i inventory/hosts.yml -v

# 4. Ver reporte completo
cat evidence/automatizacion/reports/00_REPORTE_COMPLETO.txt

# 5. Verificar tareas cron
ssh ansible@172.17.25.126
sudo crontab -l
```

---

## 📋 Comandos Detallados

### Paso 1: Aplicar Automatización

```bash
ansible-playbook playbooks/configure_automation.yml -i inventory/hosts.yml -v
```

**Qué hace:**
- Instala y configura cron
- Crea 6 scripts de automatización
- Configura 6 tareas cron
- Crea directorios de logs y backups

**Tiempo:** ~3 minutos

---

### Paso 2: Verificar Configuración

#### Ver tareas cron
```bash
ssh ansible@172.17.25.126
sudo crontab -l
```

#### Ver scripts creados
```bash
ls -la /usr/local/bin/*.sh
```

#### Ver estado de cron
```bash
sudo systemctl status cron
```

---

### Paso 3: Generar Evidencias

```bash
ansible-playbook playbooks/generar_evidencias_automatizacion.yml -i inventory/hosts.yml -v
```

**Resultado:** 8 archivos de evidencias en `evidence/automatizacion/reports/`

---

### Paso 4: Tomar Capturas

#### Captura 1: Lista de tareas cron
```bash
ssh ansible@172.17.25.126
sudo crontab -l
```
📸 **Guardar como:** `screenshots/01_tareas_cron.png`

#### Captura 2: Estado del servicio cron
```bash
sudo systemctl status cron
```
📸 **Guardar como:** `screenshots/02_estado_cron.png`

#### Captura 3: Scripts de automatización
```bash
ls -lah /usr/local/bin/*.sh
```
📸 **Guardar como:** `screenshots/03_scripts.png`

#### Captura 4: Contenido de un script
```bash
sudo cat /usr/local/bin/backup_configs.sh
```
📸 **Guardar como:** `screenshots/04_script_backup.png`

#### Captura 5: Logs de ejecución
```bash
sudo grep CRON /var/log/syslog | tail -20
```
📸 **Guardar como:** `screenshots/05_ejecuciones.png`

#### Captura 6: Logs de backup
```bash
sudo tail -30 /var/log/automation/backup_configs.log
```
📸 **Guardar como:** `screenshots/06_logs_backup.png`

#### Captura 7: Logs de monitoreo
```bash
sudo tail -30 /var/log/automation/service_monitor.log
```
📸 **Guardar como:** `screenshots/07_logs_monitoreo.png`

#### Captura 8: Backups existentes
```bash
ls -lh /backup/configs/
```
📸 **Guardar como:** `screenshots/08_backups.png`

---

### Paso 5: Probar Ejecución Manual

#### Ejecutar script de backup manualmente
```bash
sudo /usr/local/bin/backup_configs.sh
sudo tail -20 /var/log/automation/backup_configs.log
```

#### Ejecutar script de monitoreo manualmente
```bash
sudo /usr/local/bin/check_services.sh
sudo tail -20 /var/log/automation/service_monitor.log
```

#### Ejecutar script de reporte manualmente
```bash
sudo /usr/local/bin/system_report.sh
ls -la /var/log/automation/system_report_*.log
```

---

## ✅ Checklist de Evidencias

### Configuración
- [ ] Tareas cron listadas
- [ ] Estado de cron activo
- [ ] Scripts creados (6)
- [ ] Directorios creados

### Ejecución
- [ ] Logs de syslog con ejecuciones
- [ ] Logs de backup
- [ ] Logs de monitoreo
- [ ] Logs de limpieza

### Validación
- [ ] Backups generados
- [ ] Servicios monitoreados
- [ ] Reportes generados
- [ ] Logs rotados

### Documentación
- [ ] Reporte completo generado
- [ ] 8 capturas de pantalla
- [ ] Evidencias organizadas

---

## 🎯 Qué Demuestras

### ✅ Automatización Robusta
- 6 tareas cron configuradas
- 6 scripts de automatización
- Ejecución programada
- Logs detallados

### ✅ Validación
- Servicio cron activo
- Tareas ejecutándose
- Logs de ejecución
- Resultados verificables

### ✅ Mantenimiento Automático
- Backups automáticos
- Limpieza automática
- Actualizaciones automáticas
- Monitoreo continuo

---

## 📊 Matriz de Cumplimiento

| Criterio | Implementado | Evidencia |
|----------|--------------|-----------|
| Tareas cron | ✅ | 6 tareas |
| Scripts | ✅ | 6 scripts |
| Logs | ✅ | Detallados |
| Validación | ✅ | Syslog |
| Backup | ✅ | Automático |
| Monitoreo | ✅ | Continuo |

**NIVEL: ⭐⭐⭐⭐⭐**

---

## 🆘 Troubleshooting

### Cron no está activo
```bash
sudo systemctl start cron
sudo systemctl enable cron
```

### Tareas no se ejecutan
```bash
# Verificar sintaxis
sudo crontab -l

# Ver logs
sudo grep CRON /var/log/syslog
```

### Scripts no tienen permisos
```bash
sudo chmod +x /usr/local/bin/*.sh
```

---

**¡Éxito con tu automatización!** 🚀

**Nivel alcanzado:** ⭐⭐⭐⭐⭐ "Automatización robusta y validada"

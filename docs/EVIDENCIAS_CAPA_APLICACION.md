# 📋 Evidencias de Competencia en Capa de Aplicación

Este documento explica cómo generar evidencias automáticas para demostrar competencia en la configuración y validación de servicios HTTP y FTP.

## 🎯 Objetivo

Demostrar competencia en la **Capa de Aplicación** mediante:
- ✅ Configuración de servicios funcionales (HTTP, FTP)
- ✅ Validación con pruebas reales de conexión
- ✅ Descarga de archivos desde múltiples clientes
- ✅ Conectividad IPv6 end-to-end

## 🏗️ Arquitectura

```
┌─────────────────────┐
│   debian-router     │
│  2025:db8:101::1    │
│                     │
│  • Apache2 (HTTP)   │
│  • vsftpd (FTP)     │
└──────────┬──────────┘
           │
           ├───────────────────┬───────────────────┐
           │                   │                   │
    ┌──────▼──────┐     ┌──────▼──────┐    ┌──────▼──────┐
    │ ubuntu-pc   │     │ windows-pc  │    │  Internet   │
    │ ::10        │     │ ::11        │    │             │
    │             │     │             │    │             │
    │ curl/wget   │     │ PowerShell  │    │ via NAT     │
    │ lftp        │     │ FTP client  │    │             │
    └─────────────┘     └─────────────┘    └─────────────┘
```

## 🚀 Ejecución Rápida

### Opción 1: Script Automatizado (Recomendado)

```bash
cd ~/ansible
./scripts/generate_evidence.sh
```

### Opción 2: Playbook Directo

```bash
cd ~/ansible
ansible-playbook playbooks/generate_app_layer_evidence.yml -i inventory/hosts.yml -vv
```

## 📊 Pruebas Realizadas

### 🌐 Pruebas HTTP

| Cliente | Herramienta | Prueba | IPv6 |
|---------|-------------|--------|------|
| Ubuntu | curl | Conexión web | ✅ |
| Ubuntu | wget | Descarga de página | ✅ |
| Windows | PowerShell Invoke-WebRequest | Conexión web | ✅ |
| Windows | PowerShell | Descarga de archivo | ✅ |

### 📁 Pruebas FTP

| Cliente | Herramienta | Prueba | IPv6 |
|---------|-------------|--------|------|
| Ubuntu | lftp | Listar archivos | ✅ |
| Ubuntu | lftp | Descarga de archivo | ✅ |
| Windows | FTP nativo | Conexión y listado | ✅ |
| Windows | FTP nativo | Descarga de archivo | ✅ |

## 📄 Evidencias Generadas

Después de ejecutar el playbook, se generarán los siguientes archivos en `evidence/capa_aplicacion/`:

```
evidence/capa_aplicacion/
├── 00_RESUMEN.txt                      # Resumen inicial
├── REPORTE_FINAL_CAPA_APLICACION.txt   # 📊 REPORTE PRINCIPAL
├── servidor_evidencias.txt             # Estado de servicios
├── ubuntu_evidencias.txt               # Pruebas desde Ubuntu
├── windows_evidencias.txt              # Pruebas desde Windows
└── ejecucion_YYYYMMDD_HHMMSS.log      # Log de ejecución
```

### 📖 Archivo Principal: `REPORTE_FINAL_CAPA_APLICACION.txt`

Este archivo contiene:
- ✅ Resumen ejecutivo
- ✅ Lista de servicios configurados
- ✅ Clientes probados
- ✅ Competencias demostradas
- ✅ Detalles técnicos completos

## 🔍 Contenido de las Evidencias

### 1️⃣ Servidor (debian-router)
- Estado de servicios Apache2 y vsftpd
- Puertos en escucha (80, 21)
- Conexiones activas
- Logs recientes de ambos servicios

### 2️⃣ Cliente Ubuntu
- Configuración de red IPv6
- Resultados de curl y wget (HTTP)
- Contenido descargado vía HTTP
- Resultados de lftp (FTP)
- Archivo descargado vía FTP
- Test de conectividad IPv6

### 3️⃣ Cliente Windows
- Configuración de red IPv6
- Resultados de PowerShell Invoke-WebRequest
- Contenido descargado vía HTTP
- Resultados de cliente FTP nativo
- Archivo descargado vía FTP
- Test de conectividad IPv6

## ✅ Criterios de Éxito

Una ejecución exitosa debe mostrar:

```
✓ Apache2: ACTIVO
✓ vsftpd: ACTIVO
✓ Puerto 80: ESCUCHANDO
✓ Puerto 21: ESCUCHANDO
✓ HTTP IPv6 Ubuntu: EXITOSO
✓ FTP IPv6 Ubuntu: EXITOSO
✓ HTTP IPv6 Windows: EXITOSO
✓ FTP IPv6 Windows: EXITOSO
✓ Ping IPv6: EXITOSO
```

## 🛠️ Requisitos Previos

Antes de ejecutar las evidencias, asegúrate de que:

1. ✅ Apache2 esté corriendo en debian-router
2. ✅ vsftpd esté corriendo en debian-router
3. ✅ Ubuntu y Windows tengan conectividad IPv6
4. ✅ Usuario FTP `ftpuser` esté creado (automático)

### Verificación rápida:

```bash
# En debian-router
systemctl status apache2
systemctl status vsftpd
netstat -tlnp | grep -E ':80|:21'

# En ubuntu-pc
ping -6 -c 4 2025:db8:101::1

# En windows-pc (PowerShell)
ping -6 -n 4 2025:db8:101::1
```

## 🔧 Solución de Problemas

### Apache no inicia

```bash
# Ver logs
journalctl -u apache2 -n 50

# Verificar configuración
apache2ctl configtest

# Si hay problemas con ports.conf, ejecutar:
ansible-playbook playbooks/deploy_http_service.yml -i inventory/hosts.yml
```

### FTP no conecta

```bash
# Verificar que escucha en IPv6
netstat -tlnp | grep :21

# Ver logs
journalctl -u vsftpd -n 50

# Probar localmente
echo "bye" | ftp localhost
```

### Windows no puede descargar

```powershell
# Verificar IPv6
Get-NetIPAddress -AddressFamily IPv6 | Where-Object {$_.IPAddress -like "2025:*"}

# Probar conectividad
ping -6 2025:db8:101::1

# Probar HTTP manualmente
Invoke-WebRequest -Uri "http://[2025:db8:101::1]" -UseBasicParsing
```

## 📸 Capturas de Pantalla Recomendadas

Para complementar las evidencias automáticas, se recomienda capturar:

1. **Servidor**: Terminal mostrando `systemctl status apache2 vsftpd`
2. **Ubuntu**: Terminal con `curl` descargando desde el servidor
3. **Ubuntu**: Terminal con `lftp` descargando archivo
4. **Windows**: PowerShell con `Invoke-WebRequest` exitoso
5. **Windows**: Cliente FTP descargando archivo
6. **Navegador Ubuntu**: Página web en `http://[2025:db8:101::1]`
7. **Navegador Windows**: Página web en `http://[2025:db8:101::1]`

## 📚 Referencias

- [Apache2 Documentation](https://httpd.apache.org/docs/2.4/)
- [vsftpd Configuration](https://security.appspot.com/vsftpd/vsftpd_conf.html)
- [IPv6 Testing Best Practices](https://www.ripe.net/support/training/material/ipv6-for-ixps-tutorial/testing-ipv6-connectivity)

## 🎓 Competencias Demostradas

Con estas evidencias se demuestra:

- ✅ **Configuración de servicios**: Apache2 y vsftpd en entorno IPv6
- ✅ **Validación funcional**: Pruebas reales de conexión desde clientes
- ✅ **Descarga de archivos**: HTTP y FTP operacionales
- ✅ **Automatización**: Generación de evidencias con Ansible
- ✅ **Documentación**: Reportes detallados y estructurados
- ✅ **Troubleshooting**: Logs y diagnósticos incluidos

---

**Fecha de creación**: 2025-11-21  
**Versión**: 1.0  
**Autor**: Ansible Automation

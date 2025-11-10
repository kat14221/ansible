# 🖥️ Network Monitor Dashboard

Herramienta web profesional para monitoreo visual de dispositivos en la red IPv6 `2025:db8:101::/64` del proyecto VMWARE-101001.

## 📊 Características

✅ **Detección Automática de Dispositivos**
- Escaneo de toda la subnet IPv6
- Identificación de hostname y SO
- Resolución de direcciones MAC
- Medición de latencia

✅ **Dashboard Interactivo**
- Interfaz web moderna (Bootstrap 5)
- Visualización en tiempo real
- Búsqueda y filtrado
- Estadísticas por dispositivo

✅ **Herramientas Integradas**
- Conexión SSH directa desde web
- Ping/traceroute a dispositivos
- Exportación de datos (JSON/CSV)
- Auto-actualización

✅ **Monitoreo Continuo**
- API REST completa
- WebSocket para actualizaciones reales
- Historial de dispositivos
- Alertas de cambios

## 🚀 Instalación Rápida

### Opción 1: Ansible (Recomendado)

```bash
# En tu máquina de control
ansible-playbook playbooks/deploy_network_monitor.yml \
  -i inventory/hosts.yml \
  -u ansible
```

### Opción 2: Manual

```bash
# En debian-router
cd /opt/network-monitor

# Crear virtualenv
python3 -m venv venv
source venv/bin/activate

# Instalar dependencias
pip install -r requirements.txt

# Ejecutar aplicación
python3 app.py
```

## 📍 Acceso

Una vez instalado, accede a través de:

| Método | URL |
|--------|-----|
| **Web Browser** | `http://debian-router:5000` |
| **IPv6 Directo** | `http://[2025:db8:101::1]:5000` |
| **SSH + Port Forward** | `ssh -L 5000:localhost:5000 ansible@2025:db8:101::1` |

## 🔍 Uso del Dashboard

### 1. Escaneo Manual

```
Botón: "Escanear Red"
├─ Detecta dispositivos activos
├─ Obtiene información (hostname, MAC, OS)
├─ Mide latencia
└─ Actualiza tabla
```

### 2. Búsqueda y Filtrado

```
Campo: "Buscar dispositivo..."
├─ Busca por hostname
├─ Busca por IPv6
├─ Busca por MAC
└─ Filtra tabla en tiempo real
```

### 3. Acciones por Dispositivo

| Botón | Función |
|-------|---------|
| **🖥️ Terminal** | Generar comando SSH |
| **ℹ️ Info** | Ver detalles completos |
| **📡 Ping** | Verificar conectividad |

### 4. Auto-actualización

```
Botón: "Auto Refresh (OFF)"
├─ Activar: ejecuta escaneo cada 30s
├─ Desactivar: detiene actualizaciones
└─ Útil para monitoreo continuo
```

### 5. Exportar Datos

```
Botón: "Exportar JSON"
├─ Descarga lista de dispositivos
├─ Formato: JSON estructurado
├─ Útil para análisis/backup
└─ Incluye timestamp
```

## 🔐 Conexión SSH Integrada

1. Selecciona dispositivo en tabla
2. Click en botón **"🖥️ Terminal"**
3. Modal muestra comando SSH
4. Click **"Copiar"**
5. Pega en tu terminal local

```bash
# Ejemplo de comando generado
ssh -6 ansible@2025:db8:101::10

# Si quieres cambiar usuario:
# - Edita campo "Usuario" en modal
# - Selecciona nuevo usuario (root, operator, etc)
# - Click "Copiar"
```

## 📊 API REST

La aplicación expone una API REST completa:

### GET /api/devices
Obtener lista de dispositivos

```bash
curl http://debian-router:5000/api/devices
```

Respuesta:
```json
{
  "status": "success",
  "device_count": 5,
  "timestamp": "2025-11-10T14:30:00Z",
  "devices": [
    {
      "ipv6": "2025:db8:101::1",
      "hostname": "debian-router",
      "mac": "aa:bb:cc:dd:ee:01",
      "status": "online",
      "os": "Linux"
    }
  ]
}
```

### GET /api/device/{ipv6}
Obtener detalles de un dispositivo

```bash
curl http://debian-router:5000/api/device/2025:db8:101::10
```

### POST /api/ssh/{ipv6}
Generar comando SSH

```bash
curl -X POST http://debian-router:5000/api/ssh/2025:db8:101::10 \
  -H "Content-Type: application/json" \
  -d '{"user":"ansible"}'
```

### GET /api/ping/{ipv6}
Hacer ping a dispositivo

```bash
curl http://debian-router:5000/api/ping/2025:db8:101::10
```

### GET /api/stats
Obtener estadísticas generales

```bash
curl http://debian-router:5000/api/stats
```

### GET /api/export
Exportar datos

```bash
# JSON
curl http://debian-router:5000/api/export?format=json > devices.json

# CSV
curl http://debian-router:5000/api/export?format=csv > devices.csv
```

## 📁 Estructura de Archivos

```
/opt/network-monitor/
├── app.py                      # Aplicación Flask principal
├── network_scanner.py          # Módulo de escaneo
├── requirements.txt            # Dependencias Python
├── venv/                       # Virtualenv
├── templates/
│   └── index.html             # Dashboard HTML
├── static/
│   ├── app.js                 # JavaScript del frontend
│   └── style.css              # Estilos Bootstrap personalizado
└── logs/
    └── app.log                # Log de aplicación
```

## 🔧 Configuración

### Variables de Entorno

```bash
# En /opt/network-monitor/.env (crear si no existe)
FLASK_ENV=production
FLASK_DEBUG=False
PORT=5000
INTERFACE=ens192
SUBNET=2025:db8:101::/64
```

### Archivo de Configuración

Editar en `app.py`:

```python
# Línea ~80
app.config.update(
    JSON_AS_ASCII=False,
    JSON_SORT_KEYS=False,
    TEMPLATES_AUTO_RELOAD=False  # True en desarrollo
)
```

## 📈 Monitoreo del Servicio

### Ver logs en tiempo real

```bash
# Logs de systemd
tail -f /var/log/network-monitor/app.log

# O con journalctl
journalctl -u network-monitor -f
```

### Estado del servicio

```bash
# Ver estado
systemctl status network-monitor

# Restart
systemctl restart network-monitor

# Stop
systemctl stop network-monitor

# Start
systemctl start network-monitor
```

### Verificar conectividad

```bash
# Test de API
curl -v http://localhost:5000/api/devices

# Test de página web
curl -I http://localhost:5000/

# Test con timeout
curl --max-time 5 http://localhost:5000/
```

## 🐛 Troubleshooting

### El dashboard no carga

```bash
# 1. Verificar que el servicio está corriendo
systemctl status network-monitor

# 2. Ver logs de error
tail -50 /var/log/network-monitor/app.log

# 3. Restart del servicio
systemctl restart network-monitor

# 4. Verificar firewall
firewall-cmd --list-all
firewall-cmd --zone=internal --add-port=5000/tcp --permanent
firewall-cmd --reload
```

### No se detectan dispositivos

```bash
# 1. Verificar que ping6 funciona
ping6 -c 1 2025:db8:101::10

# 2. Verificar que nmap está instalado (opcional pero recomendado)
which nmap

# 3. Verificar logs
tail -f /var/log/network-monitor/app.log

# 4. Test manual de escaneo
curl http://localhost:5000/api/scan
```

### Error de permisos

```bash
# El servicio debe correr como root para usar ping6
# Verificar usuario en systemd
grep User= /etc/systemd/system/network-monitor.service

# Si necesitas cambiar usuario:
# 1. Editar /etc/systemd/system/network-monitor.service
# 2. User=ansible (o el usuario que necesites)
# 3. sudo systemctl daemon-reload
# 4. sudo systemctl restart network-monitor
```

### Puerto 5000 en uso

```bash
# Ver qué proceso está usando el puerto
lsof -i :5000
netstat -tulpn | grep 5000

# Cambiar puerto en app.py línea ~300:
app.run(host='0.0.0.0', port=5001, debug=False)  # Cambiar 5000 a 5001
```

## 📱 Dispositivos Soportados

La herramienta puede detectar:

| Tipo | Métodos | Ejemplos |
|------|---------|----------|
| **Linux** | ping6, ARP | Debian, Ubuntu, CentOS |
| **Windows** | ping6, ARP | Windows 10, 11, Server |
| **macOS** | ping6, ARP | OS X, macOS |
| **Cisco IOS** | ping6, SNMP | Routers, Switches |
| **IoT/Embedded** | ping6, mDNS | Raspberry Pi, Arduino |

## ⚡ Optimización

### Para Red Grande (>100 dispositivos)

```python
# En network_scanner.py, línea ~60
# Aumentar timeouts
TIMEOUT = 10  # segundos
RETRIES = 3

# Aumentar paralelismo
THREADS = 10  # procesamiento paralelo
```

### Caché de Resultados

```bash
# Los resultados se cachean por 5 minutos
# Para forzar nuevo escaneo:
curl http://localhost:5000/api/scan

# Para usar caché:
curl http://localhost:5000/api/devices
```

## 🔐 Seguridad

### Acceso Restringido

Si quieres limitar acceso a la aplicación:

```bash
# Opción 1: Firewall
firewall-cmd --zone=internal --add-source=2025:db8:101::/64 --permanent
firewall-cmd --zone=internal --add-port=5000/tcp --permanent
firewall-cmd --reload

# Opción 2: Nginx Reverse Proxy
# (Ver configuración en docs/)
```

### HTTPS

Para habilitar SSL en producción:

```bash
# Generar certificado autofirmado
openssl req -x509 -newkey rsa:4096 -nodes -out /opt/network-monitor/cert.pem -keyout /opt/network-monitor/key.pem -days 365

# En app.py:
app.run(host='0.0.0.0', port=5000, ssl_context=('cert.pem', 'key.pem'))
```

## 📚 Documentación

- [API REST Completa](docs/api.md)
- [Configuración Avanzada](docs/config.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Desarrollador](docs/developer.md)

## 🤝 Contribuciones

Para reportar bugs o sugerir mejoras:

```bash
# 1. Describe el problema
# 2. Incluye logs relevantes
# 3. Proporciona pasos para reproducir
```

## 📄 Licencia

Proyecto académico VMWARE-101001

---

**Versión:** 1.0  
**Última actualización:** 2025-11-10  
**Autor:** Equipo de Infraestructura  
**Estado:** ✅ En Producción

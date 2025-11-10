#!/bin/bash

################################################################################
#                     DEPLOY AND RUN - ANSIBLE PLAYBOOKS                       #
#                                                                               #
#  Este script debe ejecutarse EN LA VM CONTROL (debian-router)                #
#  Hace pull del repositorio y levanta todos los servicios                     #
#                                                                               #
################################################################################

set -e  # Exit on error

REPO_PATH="/home/ansible/ansible"
LOG_FILE="/tmp/deploy_$(date +%Y%m%d_%H%M%S).log"

echo "═══════════════════════════════════════════════════════════════════"
echo "  🚀 DEPLOY AND RUN - Network Monitor + Full Stack"
echo "═══════════════════════════════════════════════════════════════════"
echo ""
echo "📋 Logs: $LOG_FILE"
echo ""

# Función para logging
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Función para separadores
separator() {
    echo "───────────────────────────────────────────────────────────────" | tee -a "$LOG_FILE"
}

################################################################################
# PASO 1: Verificar que estamos en la VM Control
################################################################################
separator
log "📍 PASO 1: Verificar que estamos en debian-router"
separator

HOSTNAME=$(hostname)
log "Hostname actual: $HOSTNAME"

if [[ "$HOSTNAME" != "debian-router" ]]; then
    log "❌ ERROR: Este script debe ejecutarse EN debian-router"
    log "   Conecta primero: ssh ansible@172.17.25.126"
    exit 1
fi

log "✅ Estamos en debian-router correctamente"

################################################################################
# PASO 2: Git Pull
################################################################################
separator
log "📥 PASO 2: Git Pull del repositorio"
separator

cd "$REPO_PATH"
log "Ubicación: $(pwd)"

# Ver estado actual
log "Estado actual del repositorio:"
git status | tee -a "$LOG_FILE"

# Hacer pull
log "Haciendo pull de origin/main..."
git pull origin main 2>&1 | tee -a "$LOG_FILE"

log "✅ Git pull completado"

################################################################################
# PASO 3: Verificar Python y dependencias
################################################################################
separator
log "🐍 PASO 3: Verificar Python y dependencias"
separator

# Verificar Python
PYTHON_VERSION=$(python3 --version)
log "Python disponible: $PYTHON_VERSION"

# Verificar Ansible
ANSIBLE_VERSION=$(ansible --version | head -n1)
log "Ansible disponible: $ANSIBLE_VERSION"

log "✅ Dependencias verificadas"

################################################################################
# PASO 4: Validar sintaxis de playbooks
################################################################################
separator
log "🔍 PASO 4: Validar sintaxis de playbooks"
separator

log "Validando: deploy_network_monitor.yml"
ansible-playbook playbooks/deploy_network_monitor.yml --syntax-check 2>&1 | tee -a "$LOG_FILE"

log "Validando: site.yml"
ansible-playbook playbooks/site.yml --syntax-check 2>&1 | tee -a "$LOG_FILE"

log "✅ Sintaxis validada"

################################################################################
# PASO 5: Deploy Network Monitor
################################################################################
separator
log "🚀 PASO 5: Deploying Network Monitor Dashboard"
separator

log "Ejecutando: ansible-playbook playbooks/deploy_network_monitor.yml"
ansible-playbook playbooks/deploy_network_monitor.yml \
    -i inventory/hosts.yml \
    -u ansible \
    -v 2>&1 | tee -a "$LOG_FILE"

if [ $? -eq 0 ]; then
    log "✅ Network Monitor desplegado exitosamente"
else
    log "❌ Error al desplegar Network Monitor"
    exit 1
fi

################################################################################
# PASO 6: Verificar servicios
################################################################################
separator
log "✔️  PASO 6: Verificar servicios desplegados"
separator

# Verificar Network Monitor
log "Verificando Network Monitor..."
if systemctl is-active --quiet network-monitor; then
    log "✅ Network Monitor está ACTIVO"
    systemctl status network-monitor | tee -a "$LOG_FILE"
else
    log "⚠️  Network Monitor no está activo. Intentando iniciar..."
    sudo systemctl start network-monitor
    sleep 2
    systemctl status network-monitor | tee -a "$LOG_FILE"
fi

################################################################################
# PASO 7: Verificar conectividad API
################################################################################
separator
log "🌐 PASO 7: Verificar API REST"
separator

log "Esperando a que Network Monitor esté completamente iniciado..."
sleep 3

log "Probando endpoint /api/devices..."
if curl -s http://localhost:5000/api/devices > /dev/null 2>&1; then
    log "✅ API responde correctamente"
    
    # Obtener lista de dispositivos
    log "Dispositivos detectados:"
    curl -s http://localhost:5000/api/devices | python3 -m json.tool | tee -a "$LOG_FILE"
else
    log "⚠️  API aún no responde. Aguardando..."
    sleep 5
    curl -s http://localhost:5000/api/devices | python3 -m json.tool | tee -a "$LOG_FILE"
fi

################################################################################
# PASO 8: Información de acceso
################################################################################
separator
log "📊 PASO 8: Información de Acceso"
separator

log ""
log "╔═══════════════════════════════════════════════════════════════╗"
log "║                  🎉 SISTEMA LEVANTADO 🎉                     ║"
log "╚═══════════════════════════════════════════════════════════════╝"
log ""
log "📍 Network Monitor Dashboard disponible en:"
log "   • IPv4: http://172.17.25.126:5000"
log "   • IPv6: http://[2025:db8:101::1]:5000"
log ""
log "📍 API REST endpoints:"
log "   • GET  http://localhost:5000/api/devices"
log "   • GET  http://localhost:5000/api/scan"
log "   • POST http://localhost:5000/api/ssh/<ipv6>"
log ""
log "📍 Logs del sistema:"
log "   • tail -f /var/log/network-monitor/app.log"
log "   • journalctl -u network-monitor -f"
log ""
log "📍 Estado del servicio:"
log "   • systemctl status network-monitor"
log "   • systemctl restart network-monitor"
log ""
log "✅ Deploy completado exitosamente"
log "📋 Log completo: $LOG_FILE"
log ""

################################################################################
# PASO 9: Resumen de archivos importantes
################################################################################
separator
log "📁 PASO 9: Archivos importantes en el sistema"
separator

log ""
log "Network Monitor Installation:"
log "  • Aplicación: /opt/network-monitor/"
log "  • Código: /opt/network-monitor/app.py"
log "  • Logs: /var/log/network-monitor/"
log "  • Config: /etc/network-monitor/"
log ""

ls -lh /opt/network-monitor/ 2>/dev/null | tee -a "$LOG_FILE" || log "⚠️  /opt/network-monitor no accesible desde aquí"

log ""
log "Documentation:"
log "  • roles/network-monitor/README.md (400+ líneas)"
log "  • docs/TOPOLOGIA_EXTENDIDA.md (400+ líneas)"
log "  • INDICE_FINAL.md"
log ""

################################################################################
# PASO 10: Próximos pasos
################################################################################
separator
log "📋 PASO 10: Próximos Pasos"
separator

log ""
log "1️⃣  ACCEDER AL DASHBOARD:"
log "   • Abre navegador en: http://172.17.25.126:5000"
log "   • O desde IPv6: http://[2025:db8:101::1]:5000"
log ""
log "2️⃣  USAR EL DASHBOARD:"
log "   • Haz clic en 'Escanear Red' para detectar dispositivos"
log "   • Busca dispositivos por hostname/IPv6/MAC"
log "   • Haz clic en 'Terminal' para generar comandos SSH"
log "   • Exporta datos en JSON o CSV"
log ""
log "3️⃣  EXPANDIR TOPOLOGÍA (opcional):"
log "   • Lee: docs/TOPOLOGIA_EXTENDIDA.md"
log "   • Configura GNS3 con 4 VMs adicionales"
log "   • Conecta Access Point WiFi"
log "   • Monitorea 15 dispositivos totales"
log ""
log "4️⃣  TROUBLESHOOTING:"
log "   • Revisa logs: tail -f /var/log/network-monitor/app.log"
log "   • Verifica API: curl http://localhost:5000/api/devices"
log "   • Reinicia servicio: sudo systemctl restart network-monitor"
log ""

echo "═══════════════════════════════════════════════════════════════"
echo "  ✅ SCRIPT COMPLETADO EXITOSAMENTE"
echo "═══════════════════════════════════════════════════════════════"
echo ""
log "⏱️  Tiempo total: $SECONDS segundos"
log "📋 Log: $LOG_FILE"


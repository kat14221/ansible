#!/usr/bin/env bash
# ============================================================================
# Script de Auditoría Rápida del Laboratorio
# ============================================================================
# Propósito: Ejecuta Ansible en modo 'check' y 'diff' para detectar
#            cambios no autorizados en la configuración del sistema.
#
# Uso: ./scripts/run_audit.sh
# ============================================================================

set -euo pipefail

echo "=================================================="
echo "🕵️‍♂️  INICIANDO AUDITORÍA COMPLETA DEL ENTORNO"
echo "=================================================="
echo "Comparando el estado actual con la configuración deseada..."
echo "Esto puede tardar varios minutos."

# Crear directorio de reportes si no existe
mkdir -p evidence/reports

# Generar nombre de archivo con timestamp
REPORT_FILE="evidence/reports/audit_report_$(date +'%Y-%m-%d_%H-%M-%S').log"

echo "📝 El reporte detallado se guardará en: $REPORT_FILE"
echo ""

# Ejecutar Ansible en modo check y diff, guardando la salida en el log y mostrándola en pantalla
ansible-playbook playbooks/audit_and_report.yml --check --diff | tee "$REPORT_FILE"

echo ""
echo "✅ Auditoría completada."
echo "🔍 Revisa la salida anterior o el archivo '$REPORT_FILE' para ver los detalles."
echo "   Busca líneas que comiencen con '---' y '+++' (diff) o tareas en estado 'changed'."
echo "=================================================="
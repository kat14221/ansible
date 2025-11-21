#!/bin/bash

# Script de evidencias de Capa de Aplicación
# Ejecuta pruebas automáticas de HTTP y FTP

set -e

EVIDENCE_DIR="evidence/capa_aplicacion"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                                                                ║"
echo "║     GENERADOR DE EVIDENCIAS - CAPA DE APLICACIÓN              ║"
echo "║                                                                ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "📅 Fecha: $(date '+%Y-%m-%d %H:%M:%S')"
echo "📁 Directorio de evidencias: $EVIDENCE_DIR"
echo ""

# Crear directorio de evidencias
mkdir -p "$EVIDENCE_DIR"

echo "🚀 Ejecutando playbook de evidencias..."
echo ""

ansible-playbook playbooks/generate_app_layer_evidence.yml \
  -i inventory/hosts.yml \
  -vv \
  2>&1 | tee "$EVIDENCE_DIR/ejecucion_${TIMESTAMP}.log"

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "✅ EVIDENCIAS GENERADAS"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "📂 Archivos disponibles en: $EVIDENCE_DIR/"
ls -lh "$EVIDENCE_DIR/"
echo ""
echo "📖 Para ver el reporte final:"
echo "   cat $EVIDENCE_DIR/REPORTE_FINAL_CAPA_APLICACION.txt"
echo ""
echo "═══════════════════════════════════════════════════════════════"

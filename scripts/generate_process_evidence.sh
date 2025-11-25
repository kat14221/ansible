#!/bin/bash
# Script: generate_process_evidence.sh
# Propósito: Generar evidencias de Gestión de Procesos y Servicios
# Fecha: 2025-11-25

set -e  # Salir si hay error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Directorio base
ANSIBLE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ANSIBLE_DIR"

echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Generación de Evidencias: Gestión de Procesos        ${NC}"
echo -e "${BLUE}  Proyecto: VMWARE-101001                                ${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo ""

# ========================================
# 1. VERIFICACIONES PREVIAS
# ========================================
echo -e "${YELLOW}[1/5]${NC} Verificando requisitos previos..."

# Verificar que existe el playbook
if [ ! -f "playbooks/generate_process_management_evidence.yml" ]; then
    echo -e "${RED}✗ Error: No se encuentra el playbook${NC}"
    echo "  Ruta esperada: playbooks/generate_process_management_evidence.yml"
    exit 1
fi

# Verificar inventario
if [ ! -f "inventory/hosts.yml" ]; then
    echo -e "${RED}✗ Error: No se encuentra el inventario${NC}"
    echo "  Ruta esperada: inventory/hosts.yml"
    exit 1
fi

echo -e "${GREEN}✓ Archivos requeridos encontrados${NC}"
echo ""

# ========================================
# 2. VERIFICAR CONECTIVIDAD
# ========================================
echo -e "${YELLOW}[2/5]${NC} Verificando conectividad con debian-router..."

if ansible -i inventory/hosts.yml debian_router -m ping > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Conectividad SSH OK${NC}"
else
    echo -e "${RED}✗ Error: No se puede conectar a debian-router${NC}"
    echo ""
    echo "Posibles soluciones:"
    echo "  1. Verificar que debian-router esté encendido"
    echo "  2. Verificar la IP en inventory/hosts.yml"
    echo "  3. Probar conexión manual: ssh ansible@172.17.25.126"
    exit 1
fi
echo ""

# ========================================
# 3. CREAR DIRECTORIO DE EVIDENCIAS
# ========================================
echo -e "${YELLOW}[3/5]${NC} Preparando directorio de evidencias..."

EVIDENCE_DIR="evidence/gestion_procesos"
if [ ! -d "$EVIDENCE_DIR" ]; then
    mkdir -p "$EVIDENCE_DIR"
    echo -e "${GREEN}✓ Directorio creado: $EVIDENCE_DIR${NC}"
else
    echo -e "${BLUE}ℹ Directorio existente: $EVIDENCE_DIR${NC}"
fi
echo ""

# ========================================
# 4. EJECUTAR PLAYBOOK
# ========================================
echo -e "${YELLOW}[4/5]${NC} Ejecutando playbook de evidencias..."
echo ""
echo -e "${BLUE}Esto tomará aproximadamente 2-3 minutos...${NC}"
echo ""

if ansible-playbook playbooks/generate_process_management_evidence.yml \
   -i inventory/hosts.yml \
   -v; then
    echo ""
    echo -e "${GREEN}✓ Playbook ejecutado exitosamente${NC}"
else
    echo ""
    echo -e "${RED}✗ Error durante la ejecución del playbook${NC}"
    exit 1
fi
echo ""

# ========================================
# 5. VERIFICAR RESULTADOS
# ========================================
echo -e "${YELLOW}[5/5]${NC} Verificando evidencias generadas..."

EXPECTED_FILES=(
    "00_INICIO.txt"
    "01_inventario_servicios.txt"
    "02_servicios_criticos.txt"
    "03_top_procesos_cpu.txt"
    "04_top_procesos_memoria.txt"
    "05_control_servicios.txt"
    "06_arranque_automatico.txt"
    "07_logs_servicios.txt"
    "08_prioridades_procesos.txt"
    "09_recursos_sistema.txt"
    "10_dependencias_servicios.txt"
    "REPORTE_FINAL.txt"
)

FILES_OK=0
FILES_MISSING=0

for file in "${EXPECTED_FILES[@]}"; do
    if [ -f "$EVIDENCE_DIR/$file" ]; then
        SIZE=$(du -h "$EVIDENCE_DIR/$file" | cut -f1)
        echo -e "${GREEN}✓${NC} $file ($SIZE)"
        FILES_OK=$((FILES_OK + 1))
    else
        echo -e "${RED}✗${NC} $file (faltante)"
        FILES_MISSING=$((FILES_MISSING + 1))
    fi
done

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  RESUMEN DE EJECUCIÓN${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""
echo -e "  Archivos generados: ${GREEN}$FILES_OK${NC} / ${#EXPECTED_FILES[@]}"
if [ $FILES_MISSING -gt 0 ]; then
    echo -e "  Archivos faltantes: ${RED}$FILES_MISSING${NC}"
fi
echo ""
echo -e "  📁 Ubicación: ${BLUE}$EVIDENCE_DIR/${NC}"
echo ""

# Mostrar tamaño total
TOTAL_SIZE=$(du -sh "$EVIDENCE_DIR" | cut -f1)
echo -e "  📊 Tamaño total: ${BLUE}$TOTAL_SIZE${NC}"
echo ""

# ========================================
# PRÓXIMOS PASOS
# ========================================
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  PRÓXIMOS PASOS${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""
echo "  1. Revisar el REPORTE_FINAL.txt:"
echo -e "     ${YELLOW}cat $EVIDENCE_DIR/REPORTE_FINAL.txt${NC}"
echo ""
echo "  2. Ver la guía completa de capturas:"
echo -e "     ${YELLOW}cat docs/EVIDENCIAS_GESTION_PROCESOS.md${NC}"
echo ""
echo "  3. Tomar las 11 capturas de pantalla según la guía"
echo ""
echo "  4. Agregar texto complementario a tu documento"
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"

if [ $FILES_OK -eq ${#EXPECTED_FILES[@]} ]; then
    echo ""
    echo -e "${GREEN}✓ ÉXITO: Todas las evidencias generadas correctamente${NC}"
    echo ""
    exit 0
else
    echo ""
    echo -e "${YELLOW}⚠ ADVERTENCIA: Algunas evidencias no se generaron${NC}"
    echo ""
    exit 1
fi

#!/bin/bash
# Script para validar que todas las evidencias están completas
# Proyecto: VMWARE-101001

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

EVIDENCE_DIR="evidence/usuarios_permisos"
REPORTS_DIR="$EVIDENCE_DIR/reports"
SCREENSHOTS_DIR="$EVIDENCE_DIR/screenshots"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║          VALIDADOR DE EVIDENCIAS - USUARIOS Y PERMISOS     ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Contadores
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0

# Función para verificar archivo
check_file() {
    local file="$1"
    local description="$2"
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} $description"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
        return 0
    else
        echo -e "${RED}✗${NC} $description"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
        return 1
    fi
}

# Función para verificar directorio
check_dir() {
    local dir="$1"
    local description="$2"
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    if [ -d "$dir" ]; then
        local count=$(find "$dir" -type f | wc -l)
        echo -e "${GREEN}✓${NC} $description ($count archivos)"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
        return 0
    else
        echo -e "${RED}✗${NC} $description"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
        return 1
    fi
}

# 1. VERIFICAR DOCUMENTACIÓN
echo -e "\n${BLUE}[1/5] Verificando documentación...${NC}"
check_file "docs/EVIDENCIAS_USUARIOS_PERMISOS.md" "Guía completa de evidencias"
check_file "docs/GUIA_RAPIDA_EVIDENCIAS.md" "Guía rápida"
check_file "docs/RESUMEN_ARCHIVOS_CREADOS.md" "Resumen de archivos"

# 2. VERIFICAR SCRIPTS
echo -e "\n${BLUE}[2/5] Verificando scripts...${NC}"
check_file "scripts/generar_evidencias_usuarios.sh" "Script Bash"
check_file "scripts/generar_evidencias_usuarios.ps1" "Script PowerShell"
check_file "playbooks/generar_evidencias_usuarios.yml" "Playbook Ansible"

# 3. VERIFICAR EVIDENCIAS TEXTUALES
echo -e "\n${BLUE}[3/5] Verificando evidencias textuales...${NC}"
check_file "$REPORTS_DIR/00_REPORTE_COMPLETO.txt" "Reporte completo"
check_file "$REPORTS_DIR/01_usuarios_sistema.txt" "Usuarios del sistema"
check_file "$REPORTS_DIR/02_grupos_sistema.txt" "Grupos del sistema"
check_file "$REPORTS_DIR/03_sudoers_operator.txt" "Sudoers operator"
check_file "$REPORTS_DIR/03_sudoers_ansible.txt" "Sudoers ansible"
check_file "$REPORTS_DIR/04_ssh_config.txt" "Configuración SSH"
check_file "$REPORTS_DIR/04_ssh_algorithms.txt" "Algoritmos SSH"
check_file "$REPORTS_DIR/05_fail2ban.txt" "Fail2ban"
check_file "$REPORTS_DIR/06_firewall.txt" "Firewall"
check_file "$REPORTS_DIR/07_kernel_hardening.txt" "Kernel hardening"
check_file "$REPORTS_DIR/08_resource_limits.txt" "Límites de recursos"
check_file "$REPORTS_DIR/09_auditoria.txt" "Auditoría"

# 4. VERIFICAR CAPTURAS DE PANTALLA
echo -e "\n${BLUE}[4/5] Verificando capturas de pantalla...${NC}"
check_dir "$SCREENSHOTS_DIR/01_usuarios" "Capturas de usuarios"
check_dir "$SCREENSHOTS_DIR/02_sudo" "Capturas de sudo"
check_dir "$SCREENSHOTS_DIR/03_ssh" "Capturas de SSH"
check_dir "$SCREENSHOTS_DIR/04_firewall" "Capturas de firewall"
check_dir "$SCREENSHOTS_DIR/05_hardening" "Capturas de hardening"
check_dir "$SCREENSHOTS_DIR/06_auditoria" "Capturas de auditoría"

# 5. VERIFICAR CONFIGURACIÓN EN HOSTS
echo -e "\n${BLUE}[5/5] Verificando configuración en hosts...${NC}"

# Verificar conectividad
if ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no ansible@172.17.25.126 "echo 'OK'" > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Conectividad SSH a debian-router"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
    
    # Verificar usuarios
    if ssh ansible@172.17.25.126 "getent passwd | grep -q alumno1"; then
        echo -e "${GREEN}✓${NC} Usuarios académicos creados"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        echo -e "${RED}✗${NC} Usuarios académicos NO creados"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
    fi
    
    # Verificar sudoers
    if ssh ansible@172.17.25.126 "sudo test -f /etc/sudoers.d/operator"; then
        echo -e "${GREEN}✓${NC} Configuración sudoers aplicada"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        echo -e "${RED}✗${NC} Configuración sudoers NO aplicada"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
    fi
    
    # Verificar SSH hardening
    if ssh ansible@172.17.25.126 "sudo grep -q 'PermitRootLogin no' /etc/ssh/sshd_config"; then
        echo -e "${GREEN}✓${NC} SSH hardening aplicado"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        echo -e "${RED}✗${NC} SSH hardening NO aplicado"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
    fi
    
    # Verificar firewall
    if ssh ansible@172.17.25.126 "sudo firewall-cmd --state" | grep -q "running"; then
        echo -e "${GREEN}✓${NC} Firewall activo"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        echo -e "${RED}✗${NC} Firewall NO activo"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
    fi
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 5))
else
    echo -e "${RED}✗${NC} No se puede conectar a debian-router"
    echo -e "${YELLOW}⚠${NC}  Saltando verificaciones de configuración"
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
fi

# RESUMEN
echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                    RESUMEN DE VALIDACIÓN                    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "Total de verificaciones: ${BLUE}$TOTAL_CHECKS${NC}"
echo -e "Verificaciones exitosas: ${GREEN}$PASSED_CHECKS${NC}"
echo -e "Verificaciones fallidas: ${RED}$FAILED_CHECKS${NC}"
echo ""

# Calcular porcentaje
PERCENTAGE=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))

if [ $PERCENTAGE -eq 100 ]; then
    echo -e "${GREEN}✓ ¡PERFECTO! Todas las verificaciones pasaron${NC}"
    echo -e "${GREEN}✓ Estás listo para presentar las evidencias${NC}"
    exit 0
elif [ $PERCENTAGE -ge 80 ]; then
    echo -e "${YELLOW}⚠ CASI LISTO ($PERCENTAGE%)${NC}"
    echo -e "${YELLOW}⚠ Algunas verificaciones fallaron${NC}"
    echo ""
    echo -e "Acciones recomendadas:"
    if [ ! -f "$REPORTS_DIR/00_REPORTE_COMPLETO.txt" ]; then
        echo -e "  • Ejecutar: ${BLUE}./scripts/generar_evidencias_usuarios.sh${NC}"
    fi
    if [ ! -d "$SCREENSHOTS_DIR/01_usuarios" ]; then
        echo -e "  • Tomar capturas de pantalla según la guía"
    fi
    exit 1
else
    echo -e "${RED}✗ INCOMPLETO ($PERCENTAGE%)${NC}"
    echo -e "${RED}✗ Muchas verificaciones fallaron${NC}"
    echo ""
    echo -e "Acciones recomendadas:"
    echo -e "  1. Leer: ${BLUE}docs/GUIA_RAPIDA_EVIDENCIAS.md${NC}"
    echo -e "  2. Aplicar configuración con Ansible"
    echo -e "  3. Generar evidencias: ${BLUE}./scripts/generar_evidencias_usuarios.sh${NC}"
    echo -e "  4. Tomar capturas de pantalla"
    exit 1
fi

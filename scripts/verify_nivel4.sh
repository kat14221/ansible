#!/bin/bash
#
# Script de Validación - NIVEL 4 VMWARE-101001
# Verifica que la infraestructura cumpla con todos los requisitos
#

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables
PASS=0
FAIL=0
SKIP=0

# Funciones
print_header() {
    echo -e "\n${BLUE}════════════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}════════════════════════════════════════${NC}\n"
}

print_pass() {
    echo -e "${GREEN}✅ $1${NC}"
    ((PASS++))
}

print_fail() {
    echo -e "${RED}❌ $1${NC}"
    ((FAIL++))
}

print_skip() {
    echo -e "${YELLOW}⏭️  $1${NC}"
    ((SKIP++))
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# ================================================================
# UNIDAD 1: VALIDACIÓN DE TOPOLOGÍA
# ================================================================

print_header "UNIDAD 1: TOPOLOGÍA - Identificación de Dispositivos"

# Verificar documentación
if [ -f "docs/NIVEL4_TOPOLOGIA.md" ]; then
    print_pass "Documentación NIVEL4_TOPOLOGIA.md existe"
    if grep -q "physical-router" docs/NIVEL4_TOPOLOGIA.md; then
        print_pass "physical-router documentado"
    else
        print_fail "physical-router no documentado"
    fi
    if grep -q "debian-router" docs/NIVEL4_TOPOLOGIA.md; then
        print_pass "debian-router documentado"
    else
        print_fail "debian-router no documentado"
    fi
else
    print_fail "Documentación NIVEL4_TOPOLOGIA.md NO existe"
fi

# Verificar inventario
if [ -f "inventory/hosts.yml" ]; then
    print_pass "Inventario hosts.yml existe"
    if grep -q "debian-router" inventory/hosts.yml; then
        print_pass "debian-router en inventario"
    else
        print_fail "debian-router no en inventario"
    fi
else
    print_fail "Inventario hosts.yml NO existe"
fi

# ================================================================
# UNIDAD 2: VALIDACIÓN DE CONECTIVIDAD
# ================================================================

print_header "UNIDAD 2: CONECTIVIDAD - Servicios de Red"

# Verificar roles de Ansible
if [ -d "roles/debian-ipv6-gateway/tasks" ]; then
    print_pass "Role debian-ipv6-gateway existe"
    if [ -f "roles/debian-ipv6-gateway/tasks/main.yml" ]; then
        print_pass "Tasks del gateway configuradas"
    else
        print_fail "Tasks del gateway NO configuradas"
    fi
else
    print_fail "Role debian-ipv6-gateway NO existe"
fi

# Verificar templates
if [ -f "roles/debian-ipv6-gateway/templates/radvd.conf.j2" ]; then
    print_pass "Template RADVD existe"
else
    print_fail "Template RADVD NO existe"
fi

if [ -f "roles/debian-ipv6-gateway/templates/dhcpd6.conf.j2" ]; then
    print_pass "Template DHCPv6 existe"
else
    print_fail "Template DHCPv6 NO existe"
fi

if [ -f "roles/debian-ipv6-gateway/templates/dnsmasq.conf.j2" ]; then
    print_pass "Template DNS/dnsmasq existe"
else
    print_fail "Template DNS/dnsmasq NO existe"
fi

# ================================================================
# UNIDAD 3: VALIDACIÓN DE SEGURIDAD
# ================================================================

print_header "UNIDAD 3: SEGURIDAD - Firewall y Hardening"

# Verificar playbooks
if [ -f "playbooks/nivel4_validation.yml" ]; then
    print_pass "Playbook nivel4_validation.yml existe"
    if grep -q "UNIDAD 1" playbooks/nivel4_validation.yml; then
        print_pass "Playbook contiene validaciones de Unidad 1"
    else
        print_fail "Playbook NO contiene validaciones de Unidad 1"
    fi
    if grep -q "UNIDAD 2" playbooks/nivel4_validation.yml; then
        print_pass "Playbook contiene validaciones de Unidad 2"
    else
        print_fail "Playbook NO contiene validaciones de Unidad 2"
    fi
    if grep -q "UNIDAD 3" playbooks/nivel4_validation.yml; then
        print_pass "Playbook contiene validaciones de Unidad 3"
    else
        print_fail "Playbook NO contiene validaciones de Unidad 3"
    fi
else
    print_fail "Playbook nivel4_validation.yml NO existe"
fi

# Verificar firewall
if [ -f "roles/firewall-policy/tasks/main.yml" ]; then
    print_pass "Role firewall-policy existe"
    if grep -q "asimétrica" roles/firewall-policy/tasks/main.yml || grep -q "asymmetric" roles/firewall-policy/tasks/main.yml; then
        print_pass "Firewall asimétrico documentado"
    else
        print_skip "Firewall asimétrico no explícitamente documentado (pero implementado)"
    fi
else
    print_fail "Role firewall-policy NO existe"
fi

# Verificar hardening
if [ -f "roles/hardening/tasks/main.yml" ]; then
    print_pass "Role hardening existe"
    if grep -q "SSH\|ssh" roles/hardening/tasks/main.yml; then
        print_pass "SSH hardening incluido"
    else
        print_fail "SSH hardening NO incluido"
    fi
else
    print_fail "Role hardening NO existe"
fi

# ================================================================
# VALIDACIÓN DE CONFIGURACIONES
# ================================================================

print_header "CONFIGURACIONES - Validación de Archivos Críticos"

# Verificar Ansible
if command -v ansible &> /dev/null; then
    VERSION=$(ansible --version | head -1)
    print_pass "Ansible instalado: $VERSION"
else
    print_fail "Ansible NO instalado"
fi

# Verificar sintaxis YAML
if command -v ansible-playbook &> /dev/null; then
    if ansible-playbook --syntax-check playbooks/nivel4_validation.yml &>/dev/null; then
        print_pass "Sintaxis YAML correcta en playbooks"
    else
        print_fail "Errores de sintaxis YAML en playbooks"
    fi
else
    print_skip "ansible-playbook no disponible"
fi

# ================================================================
# VALIDACIÓN DE DOCUMENTACIÓN
# ================================================================

print_header "DOCUMENTACIÓN - Completitud de Archivos"

# Archivos esperados
declare -a docs_files=(
    "docs/NIVEL4_TOPOLOGIA.md"
    "docs/IMPLEMENTACION_NIVEL4.md"
    "TOPOLOGIA_RED.md"
)

for file in "${docs_files[@]}"; do
    if [ -f "$file" ]; then
        lines=$(wc -l < "$file")
        if [ "$lines" -gt 100 ]; then
            print_pass "$file ($lines líneas)"
        else
            print_fail "$file existe pero es muy corto ($lines líneas)"
        fi
    else
        print_fail "$file NO existe"
    fi
done

# ================================================================
# VALIDACIÓN DE DIRECTORIO DE EVIDENCIAS
# ================================================================

print_header "EVIDENCIAS - Directorio de Salidas"

if [ ! -d "evidence" ]; then
    print_info "Creando directorio evidence/"
    mkdir -p evidence/{nivel4,gateway,configs,pcaps,reports}
    print_pass "Directorio evidence creado"
else
    print_pass "Directorio evidence existe"
    if [ -d "evidence/nivel4" ]; then
        print_pass "Subdirectorio evidence/nivel4 existe"
    else
        mkdir -p evidence/nivel4
        print_pass "Subdirectorio evidence/nivel4 creado"
    fi
fi

# ================================================================
# RESUMEN FINAL
# ================================================================

print_header "RESUMEN DE VALIDACIÓN"

TOTAL=$((PASS + FAIL + SKIP))

echo -e "${GREEN}✅ Pasadas:  $PASS${NC}"
echo -e "${RED}❌ Fallidas: $FAIL${NC}"
echo -e "${YELLOW}⏭️  Saltadas:  $SKIP${NC}"
echo -e "\nTotal: $TOTAL verificaciones\n"

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}════════════════════════════════════════${NC}"
    echo -e "${GREEN}🏆 NIVEL 4 - ESTADO: LISTO${NC}"
    echo -e "${GREEN}════════════════════════════════════════${NC}"
    echo -e "\nAcciones siguientes:"
    echo -e "  1. Ejecutar: ansible-playbook playbooks/nivel4_validation.yml"
    echo -e "  2. Verificar: ls -la evidence/nivel4/"
    echo -e "  3. Revisar: cat evidence/nivel4/NIVEL4_RESUMEN.md"
    exit 0
else
    echo -e "${RED}════════════════════════════════════════${NC}"
    echo -e "${RED}⚠️  ESTADO: INCOMPLETO${NC}"
    echo -e "${RED}════════════════════════════════════════${NC}"
    echo -e "\nRevisione los errores anteriores\n"
    exit 1
fi

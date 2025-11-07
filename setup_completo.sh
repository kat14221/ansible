#!/usr/bin/env bash
# 🚀 SETUP COMPLETO AUTOMÁTICO - Un solo comando para todo
# Ejecuta: ./setup_completo.sh

set -euo pipefail

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo "=========================================="
echo -e "${CYAN}🚀 SETUP COMPLETO AUTOMÁTICO${NC}"
echo -e "${CYAN}   Proyecto Ansible IPv6 VMWARE-101001${NC}"
echo "=========================================="
echo ""
echo -e "${BLUE}Este script automatiza TODO:${NC}"
echo "  ✅ Bootstrap y dependencias"
echo "  ✅ Configuración de Vault"
echo "  ✅ Permisos de archivos"
echo "  ✅ Claves SSH"
echo "  ✅ Ejecución del proyecto"
echo ""
echo -e "${YELLOW}Solo necesitas responder algunas preguntas básicas.${NC}"
echo ""

# Función para mostrar progreso
show_progress() {
    echo -e "${CYAN}[$(date '+%H:%M:%S')] $1${NC}"
}

# Función para mostrar éxito
show_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Función para mostrar error
show_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Verificar que estamos en el directorio correcto
if [ ! -f "bootstrap_control_vm.sh" ]; then
    show_error "Error: Ejecuta este script desde el directorio raíz del proyecto"
    exit 1
fi

echo "=========================================="
echo -e "${BLUE}📋 CONFIGURACIÓN INICIAL${NC}"
echo "=========================================="
echo ""

# Preguntar datos básicos una sola vez
echo -e "${YELLOW}Necesito algunos datos básicos (solo una vez):${NC}"
echo ""

read -p "IP del ESXi [168.121.48.254]: " ESXI_IP
ESXI_IP=${ESXI_IP:-168.121.48.254}

read -p "Usuario ESXi [root]: " ESXI_USER
ESXI_USER=${ESXI_USER:-root}

echo -n "Contraseña ESXi [qwe123$]: "
read -s ESXI_PASS
ESXI_PASS=${ESXI_PASS:-qwe123$}
echo ""

echo -n "Contraseña para el Vault (mínimo 8 chars): "
read -s VAULT_PASS
echo ""

if [ ${#VAULT_PASS} -lt 8 ]; then
    show_error "La contraseña del vault debe tener al menos 8 caracteres"
    exit 1
fi

echo ""
echo -e "${GREEN}¡Perfecto! Ahora todo será automático...${NC}"
echo ""

# ==========================================
# FASE 1: PERMISOS Y BOOTSTRAP
# ==========================================
show_progress "FASE 1: Configurando permisos y bootstrap..."

# Dar permisos a todos los scripts
chmod +x bootstrap_control_vm.sh 2>/dev/null || true
chmod +x scripts/*.sh 2>/dev/null || true

show_success "Permisos configurados"

# Ejecutar bootstrap si no se ha hecho
if [ ! -d "evidence/configs" ]; then
    show_progress "Ejecutando bootstrap (puede tomar 5-10 minutos)..."
    ./bootstrap_control_vm.sh
    show_success "Bootstrap completado"
else
    show_success "Bootstrap ya ejecutado anteriormente"
fi

# Ejecutar post-bootstrap
if [ -f "playbooks/bootstrap_control.yml" ]; then
    show_progress "Ejecutando post-bootstrap..."
    ansible-playbook playbooks/bootstrap_control.yml -v
    show_success "Post-bootstrap completado"
fi

# ==========================================
# FASE 2: CONFIGURACIÓN AUTOMÁTICA DE VAULT
# ==========================================
show_progress "FASE 2: Configurando Vault automáticamente..."

# Crear .vault_pass
echo "$VAULT_PASS" > .vault_pass
chmod 600 .vault_pass
show_success "Archivo .vault_pass creado"

# Crear vault.yml automáticamente
VAULT_FILE="group_vars/all/vault.yml"

# Generar clave SSH si no existe
if [ ! -f "$HOME/.ssh/id_rsa_ansible.pub" ]; then
    show_progress "Generando clave SSH..."
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_ansible -N "" -q
    show_success "Clave SSH generada"
fi

SSH_PUBLIC_KEY=$(cat ~/.ssh/id_rsa_ansible.pub 2>/dev/null || echo "")

# Crear vault.yml con datos automáticos
cat > "$VAULT_FILE" << EOF
---
# Ansible Vault - Generado automáticamente $(date '+%Y-%m-%d %H:%M:%S')

# ESXi/vCenter
vault_vcenter_hostname: "$ESXI_IP"
vault_vcenter_username: "$ESXI_USER"
vault_vcenter_password: "$ESXI_PASS"
vault_vcenter_port: 443
vault_vcenter_validate_certs: false

# Cisco IOS (valores por defecto - ajustar después si es necesario)
vault_cisco_user: "admin"
vault_cisco_password: "Ansible123!"
vault_cisco_enable_password: "Ansible123!"

# SSH Key
vault_ansible_ssh_public_key: "$SSH_PUBLIC_KEY"

# FTP/HTTP
vault_ftp_user: "ftpuser"
vault_ftp_password: "$(openssl rand -base64 12 | tr -d '/+=' | cut -c1-12)"

# Otros
vault_default_password: "Ansible123!"
EOF

show_success "Vault.yml creado con configuración automática"

# Cifrar vault
show_progress "Cifrando vault..."
ansible-vault encrypt "$VAULT_FILE" --vault-id default@.vault_pass
show_success "Vault cifrado exitosamente"

# ==========================================
# FASE 3: VERIFICACIÓN Y PREPARACIÓN
# ==========================================
show_progress "FASE 3: Verificando configuración..."

# Verificar que ansible funciona
if ansible --version >/dev/null 2>&1; then
    show_success "Ansible funcionando correctamente"
else
    show_error "Problema con Ansible"
    exit 1
fi

# Verificar collections
if ansible-galaxy collection list | grep -q "community.vmware"; then
    show_success "Collections instaladas"
else
    show_progress "Instalando collections faltantes..."
    ansible-galaxy collection install -r requirements.yml --force
    show_success "Collections instaladas"
fi

# Verificar vault
if ansible-vault view "$VAULT_FILE" --vault-password-file .vault_pass >/dev/null 2>&1; then
    show_success "Vault funcionando correctamente"
else
    show_error "Problema con el vault"
    exit 1
fi

# ==========================================
# FASE 4: EJECUCIÓN AUTOMÁTICA (OPCIONAL)
# ==========================================
echo ""
echo "=========================================="
echo -e "${BLUE}🎯 CONFIGURACIÓN COMPLETADA${NC}"
echo "=========================================="
echo ""
echo -e "${GREEN}¡Todo está listo!${NC}"
echo ""
echo -e "${YELLOW}Configuración aplicada:${NC}"
echo "  • ESXi: $ESXI_USER@$ESXI_IP"
echo "  • Vault: Cifrado y configurado"
echo "  • SSH: Claves generadas"
echo "  • Collections: Instaladas"
echo ""

read -p "¿Ejecutar el proyecto completo ahora? (s/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[SsYy]$ ]]; then
    echo ""
    echo "=========================================="
    echo -e "${CYAN}🚀 EJECUTANDO PROYECTO COMPLETO${NC}"
    echo "=========================================="
    echo ""
    
    show_progress "Iniciando despliegue completo (puede tomar 30-45 minutos)..."
    
    # Ejecutar proyecto con logs detallados
    if ansible-playbook playbooks/site.yml -vvv; then
        echo ""
        echo "=========================================="
        echo -e "${GREEN}🎉 ¡PROYECTO COMPLETADO EXITOSAMENTE!${NC}"
        echo "=========================================="
        echo ""
        echo -e "${GREEN}✅ Todas las fases ejecutadas correctamente${NC}"
        echo ""
        echo -e "${BLUE}📊 Evidencias generadas en:${NC}"
        echo "  • evidence/configs/"
        echo "  • evidence/pings/"
        echo "  • evidence/pcaps/"
        echo "  • evidence/reports/"
        echo "  • evidence/technical_reports/"
        echo ""
        echo -e "${BLUE}🌐 Servicios disponibles:${NC}"
        echo "  • HTTP: http://[2025:db8:101::1]"
        echo "  • FTP: ftp://2025:db8:101::1"
        echo "  • Reportes: evidence/technical_reports/index.html"
        echo ""
        echo -e "${BLUE}🔍 Para verificar:${NC}"
        echo "  • ssh ansible@172.17.25.126"
        echo "  • ping6 2025:db8:101::10"
        echo "  • systemctl status radvd"
        echo ""
    else
        echo ""
        echo "=========================================="
        echo -e "${YELLOW}⚠️  EJECUCIÓN CON ERRORES${NC}"
        echo "=========================================="
        echo ""
        echo -e "${YELLOW}El proyecto se ejecutó pero hubo algunos errores.${NC}"
        echo ""
        echo -e "${BLUE}Para revisar:${NC}"
        echo "  • tail -f evidence/logs/ansible.log"
        echo "  • ansible-playbook playbooks/site.yml -vvv"
        echo ""
        echo -e "${BLUE}Para ejecutar por fases:${NC}"
        echo "  • ansible-playbook playbooks/site.yml --tags network"
        echo "  • ansible-playbook playbooks/site.yml --tags vm_creation"
        echo "  • ansible-playbook playbooks/site.yml --tags debian,services"
        echo ""
    fi
else
    echo ""
    echo "=========================================="
    echo -e "${BLUE}📋 PRÓXIMOS PASOS MANUALES${NC}"
    echo "=========================================="
    echo ""
    echo -e "${GREEN}La configuración está completa. Para ejecutar:${NC}"
    echo ""
    echo -e "${CYAN}🚀 Ejecución completa:${NC}"
    echo "   ansible-playbook playbooks/site.yml -vvv"
    echo ""
    echo -e "${CYAN}🎯 Ejecución por fases:${NC}"
    echo "   ansible-playbook playbooks/site.yml --tags network"
    echo "   ansible-playbook playbooks/site.yml --tags vm_creation"
    echo "   ansible-playbook playbooks/site.yml --tags debian,services"
    echo "   ansible-playbook playbooks/site.yml --tags firewall,security"
    echo "   ansible-playbook playbooks/site.yml --tags evidence,reports"
    echo ""
    echo -e "${CYAN}📊 Generar reportes:${NC}"
    echo "   ansible-playbook playbooks/generate_reports.yml"
    echo ""
    echo -e "${CYAN}🔍 Validar conectividad:${NC}"
    echo "   ansible-playbook playbooks/validate_connectivity.yml"
    echo ""
fi

echo ""
echo "=========================================="
echo -e "${GREEN}✅ SETUP COMPLETO FINALIZADO${NC}"
echo "=========================================="
echo ""
echo -e "${BLUE}📞 Soporte:${NC}"
echo "  • Logs: tail -f evidence/logs/ansible.log"
echo "  • Guía: GUIA_COMPLETA.md"
echo "  • Config: CONFIGURACION.md"
echo ""
echo -e "${CYAN}¡Proyecto listo para usar! 🎉${NC}"
echo ""
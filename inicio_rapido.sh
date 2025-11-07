#!/usr/bin/env bash
# 🚀 INICIO RÁPIDO - Un solo comando para todo
# Ejecuta: ./inicio_rapido.sh

clear
echo "🚀 INICIO RÁPIDO - Proyecto Ansible IPv6"
echo "========================================"
echo ""
echo "Este script ejecuta TODO automáticamente con valores por defecto:"
echo "  • ESXi: 168.121.48.254 (root/qwe123$)"
echo "  • Vault: Contraseña automática"
echo "  • Configuración: Automática"
echo "  • Ejecución: Completa"
echo ""
read -p "¿Continuar con configuración automática? (s/n): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[SsYy]$ ]]; then
    echo "Cancelado. Para configuración personalizada usa: ./setup_completo.sh"
    exit 0
fi

echo ""
echo "🔄 Iniciando configuración automática..."
echo ""

# Dar permisos
chmod +x *.sh scripts/*.sh 2>/dev/null || true

# Ejecutar bootstrap
echo "📦 Ejecutando bootstrap..."
./bootstrap_control_vm.sh

# Post-bootstrap
echo "⚙️ Configuración post-bootstrap..."
ansible-playbook playbooks/bootstrap_control.yml -v

# Crear vault automático
echo "🔐 Configurando vault automático..."
echo "AutoVault123!" > .vault_pass
chmod 600 .vault_pass

# Generar SSH key si no existe
if [ ! -f "$HOME/.ssh/id_rsa_ansible.pub" ]; then
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_ansible -N "" -q
fi

SSH_KEY=$(cat ~/.ssh/id_rsa_ansible.pub 2>/dev/null || echo "")

# Crear vault.yml automático
cat > group_vars/all/vault.yml << EOF
---
# Vault automático generado $(date)
vault_vcenter_hostname: "168.121.48.254"
vault_vcenter_username: "root"
vault_vcenter_password: "qwe123$"
vault_vcenter_port: 443
vault_vcenter_validate_certs: false
vault_cisco_user: "admin"
vault_cisco_password: "Ansible123!"
vault_cisco_enable_password: "Ansible123!"
vault_ansible_ssh_public_key: "$SSH_KEY"
vault_ftp_user: "ftpuser"
vault_ftp_password: "ftppass123"
EOF

# Cifrar vault
ansible-vault encrypt group_vars/all/vault.yml --vault-id default@.vault_pass

echo ""
echo "✅ Configuración completada. Ejecutando proyecto..."
echo ""

# Ejecutar proyecto
ansible-playbook playbooks/site.yml -vvv

echo ""
echo "🎉 ¡PROYECTO COMPLETADO!"
echo ""
echo "📊 Ver evidencias: ls -la evidence/"
echo "🌐 HTTP: http://[2025:db8:101::1]"
echo "📋 Logs: tail -f evidence/logs/ansible.log"
echo ""
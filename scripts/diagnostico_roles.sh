#!/bin/bash
# Script de diagnóstico para verificar roles de Ansible

echo "╔════════════════════════════════════════════════════════════╗"
echo "║          DIAGNÓSTICO DE ROLES - VMWARE-101001              ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Verificar variables indefinidas en roles
echo "[1/3] Verificando variables indefinidas..."
echo ""

# Buscar vault_ansible_user (no debería existir)
if grep -r "vault_ansible_user" roles/ 2>/dev/null; then
    echo "❌ ERROR: Encontradas referencias a vault_ansible_user"
    echo "   Ejecuta: grep -r 'vault_ansible_user' roles/"
else
    echo "✅ No se encontraron referencias a vault_ansible_user"
fi

echo ""

# Verificar que se usa ansible_user correctamente
echo "[2/3] Verificando uso correcto de ansible_user..."
echo ""

if grep -r "ansible_user | default" roles/hardening/ roles/ssh-hardening/ 2>/dev/null | grep -q "ansible_user"; then
    echo "✅ Roles usan ansible_user con default correcto"
else
    echo "⚠️  ADVERTENCIA: No se encontró uso de ansible_user"
fi

echo ""

# Verificar sintaxis de playbooks
echo "[3/3] Verificando sintaxis de playbooks..."
echo ""

for playbook in playbooks/*.yml; do
    if [ -f "$playbook" ]; then
        if ansible-playbook "$playbook" --syntax-check 2>/dev/null; then
            echo "✅ $(basename $playbook): Sintaxis correcta"
        else
            echo "❌ $(basename $playbook): Error de sintaxis"
        fi
    fi
done

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                    RESUMEN                                  ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "Si todos los checks son ✅, puedes ejecutar:"
echo ""
echo "  ansible-playbook playbooks/site.yml -i inventory/hosts.yml --tags hardening -v"
echo ""

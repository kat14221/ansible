#!/usr/bin/env bash
# Configuración por defecto para automatización completa

# ESXi/vCenter por defecto
DEFAULT_ESXI_IP="168.121.48.254"
DEFAULT_ESXI_USER="root"
DEFAULT_ESXI_PASS="qwe123$"

# Cisco IOS por defecto
DEFAULT_CISCO_USER="admin"
DEFAULT_CISCO_PASS="Ansible123!"

# Vault por defecto
DEFAULT_VAULT_PASS="AutoVault123!"

# FTP por defecto
DEFAULT_FTP_USER="ftpuser"
DEFAULT_FTP_PASS="ftppass123"

# Red IPv6 por defecto
DEFAULT_IPV6_NETWORK="2025:db8:101::/64"
DEFAULT_IPV6_GATEWAY="2025:db8:101::1"

# Configuración de automatización
AUTO_EXECUTE_PROJECT=true
AUTO_GENERATE_SSH_KEYS=true
AUTO_COPY_SSH_KEYS=false  # Solo cuando hosts estén listos
AUTO_UPDATE_INVENTORY=true

echo "Configuración por defecto cargada para automatización completa"
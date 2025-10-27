#!/bin/bash

# Obtener la IP de la interfaz WAN (ens224)
NEW_IP=$(ip -4 addr show ens224 | grep -oP 'inet \K[\d.]+')

if [ -z "$NEW_IP" ]; then
    echo "Error: No se pudo obtener la IP de ens224"
    exit 1
fi

# Actualizar el inventario
sed -i "s/ansible_host: \"[0-9.]*\"/ansible_host: \"$NEW_IP\"/" /home/pc02/proyectos/ansible-debian/inventory/hosts.yml

echo "Inventario actualizado con la nueva IP: $NEW_IP"
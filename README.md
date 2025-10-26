# Proyecto Ansible: Red Académica IPv6 VMWARE-101001

## Descripción

Este proyecto automatiza la creación y configuración de una red académica IPv6 usando Ansible para gestionar VMs en VMware ESXi y equipos Cisco IOS.

## ⚠️ Nota Importante

**Las VMs se crearán desde ISOs y la instalación del SO debe completarse manualmente.**

Después de ejecutar los playbooks, deberás:
1. Instalar el SO en cada VM desde el ISO montado
2. Configurar las direcciones IPv6 según el inventario
3. Configurar el adaptador físico en "Red Fernandez" para conectividad al backbone

## Arquitectura

- **Backbone**: 2025:DB8:101::/64
- **LAN VMWARE-101001**: 2025:DB8:220::/64
- **Router**: vm-debian-router (2025:db8:220::1/64)
- **Hosts**: vm-ubuntu-pc (2025:db8:220::10/64), vm-windows-pc (2025:db8:220::11/64)

## Requisitos

- Ansible 2.9+
- Collections: `cisco.ios`, `community.vmware`, `ansible.netcommon`
- Acceso al ESXi: 168.121.48.254
- VM de control dentro del ESXi para ejecutar los playbooks

## Configuración

### Credenciales ESXi (configuradas en inventory/hosts.yml)
- URL: https://168.121.48.254:10101/ui/#/login
- Usuario: root
- Contraseña: qwe123$

### ISOs (en datastore1)
- Debian: `datastore1:debian/debian-12.12.0-amd64-netinst.iso`
- Ubuntu: `datastore1:ubuntu/ubuntu-24.04.2-desktop-amd64.iso`
- Windows: `datastore1:W-11/Win11_24H2_Spanish_x64.iso`

## Ejecución

### Opción 1: Playbook Maestro (Todo de una vez)
```bash
ansible-playbook playbooks/site.yml -vvv
# Crear VMs
ansible-playbook playbooks/create_vm_router.yml -vvv
ansible-playbook playbooks/create_vm_ubuntu.yml -vvv
ansible-playbook playbooks/create_vm_windows.yml -vvv

# Configurar IOS
ansible-playbook playbooks/configure_ios_router.yml -vvv
ansible-playbook playbooks/configure_switch_svi.yml -vvv

# Configurar Debian
ansible-playbook playbooks/configure_debian_ipv6.yml -vvv
ansible-playbook playbooks/configure_dhcpv6.yml -vvv

# Desplegar servicios HTTP/FTP
ansible-playbook playbooks/deploy_http_service.yml -vvv

# Tests y capturas
ansible-playbook playbooks/test_connectivity.yml -vvv
ansible-playbook playbooks/capture_traffic.yml -vvv
ansible-playbook playbooks/deploy_all.yml --tags step1  # IOS
ansible-playbook playbooks/deploy_all.yml --tags step2  # VMs
ansible-playbook playbooks/deploy_all.yml --tags step3  # Router
ansible-playbook playbooks/deploy_all.yml --tags step4  # Servicios
# Después de crear las VMs:
# 1. Instalar el SO en cada VM manualmente
# 2. Configurar IPv6 según el inventario
# 3. Agregar adaptador físico a "Red Fernandez" en el ESXi
# 4. Verificar conectividad

# Ejecutar configuración de router y tests
ansible-playbook playbooks/deploy_all.yml --tags step3,step4
```

## Documentación

- `README.md` - Este archivo
- `NOTA_EJECUCION.md` - Instrucciones detalladas de ejecución
- `RESUMEN_CONFIGURACION.md` - Resumen de configuración
- `GUIA_USO.md` - Guía de uso rápida

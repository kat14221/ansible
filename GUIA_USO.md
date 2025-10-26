# Guía de Uso Rápida - Proyecto IPv6 VMWARE-101001

## Inicio Rápido

### 1. Preparación del Entorno

```bash
# Instalar Ansible (si no está instalado)
sudo apt update
sudo apt install -y ansible python3-pip sshpass

# Instalar collections de Ansible
ansible-galaxy collection install cisco.ios community.vmware ansible.netcommon

# Verificar instalación
ansible --version
```

### 2. Configurar Credenciales

Editar `inventory/hosts.yml` y actualizar:

- **Passwords de ESXi**: `ansible_password` en esxi-vmware-host
- **Passwords de IOS**: `ansible_password` en ios-core-router y access-switch
- **Credenciales SSH**: Para debian-router, ubuntu-pc, windows-pc

### 3. Probar Conectividad

```bash
# Verificar que el inventario es correcto
ansible-inventory -i inventory/hosts.yml --list

# Probar conexión a dispositivos IOS
ansible all_ios -i inventory/hosts.yml -m ping

# Probar conexión a VMs (si ya están creadas)
ansible all_vms -i inventory/hosts.yml -m ping
```

## Ejecución del Proyecto

### Opción 1: Ejecución Completa (Recomendada)

Ejecuta todo el despliegue en una sola pasada:

```bash
# Ejecutar todo el proyecto
ansible-playbook playbooks/site.yml -vvv

# Si hay errores, ver logs
tail -f evidence/logs/ansible.log
```

### Opción 2: Ejecución Paso a Paso

Si prefieres verificar cada paso:

```bash
# Paso 1: Configurar routers y switches IOS
ansible-playbook playbooks/deploy_all.yml --tags step1

# Paso 2: Crear VMs en ESXi
ansible-playbook playbooks/deploy_all.yml --tags step2

# Paso 3: Configurar router IPv6
ansible-playbook playbooks/deploy_all.yml --tags step3

# Paso 4: Desplegar servicios
ansible-playbook playbooks/deploy_all.yml --tags step4
```

### Opción 3: Solo Componentes Específicos

```bash
# Solo configurar IOS
ansible-playbook playbooks/site.yml --tags ios

# Solo configurar Debian
ansible-playbook playbooks/site.yml --tags debian

# Solo servicios
ansible-playbook playbooks/site.yml --tags services

# Solo tests de conectividad
ansible-playbook playbooks/test_only.yml
```

## Verificación Manual

Después de ejecutar los playbooks, verifica manualmente:

### 1. Verificar Configuración IOS

```bash
# Acceder al router
ssh cisco@2025:db8:101::1

# Ver configuración IPv6
show ipv6 interface brief
show ipv6 route
show running-config | include ipv6
```

### 2. Verificar Router Debian

```bash
# Acceder al router
ssh ansible@2025:db8:220::1

# Verificar servicios
systemctl status radvd
systemctl status dnsmasq
systemctl status apache2

# Verificar forwarding IPv6
cat /proc/sys/net/ipv6/conf/all/forwarding

# Ver interfaces IPv6
ip -6 addr show
ip -6 route show

# Ver logs de RADVD
journalctl -u radvd -n 50
```

### 3. Verificar Hosts

```bash
# En Ubuntu PC
ssh ansible@2025:db8:220::10

# Verificar configuración IPv6 automática
ip -6 addr show
ip -6 route show

# Verificar DNS
cat /etc/resolv.conf

# Probar conectividad
ping6 2025:db8:220::1
ping6 2025:db8:101::1
```

### 4. Verificar Servicios

```bash
# Probar HTTP desde cualquier host
curl http://[2025:db8:220::1]
curl http://[2025:db8:101::a1]

# Desde Windows (PowerShell)
Invoke-WebRequest -Uri "http://[2025:db8:220::1]"

# Verificar DNS
nslookup router.vmware-101001.example.local
```

## Análisis de Tráfico

### Ver Capturas PCAP

```bash
# Ver capturas en Wireshark
wireshark evidence/pcaps/*.pcap

# O con tshark (línea de comandos)
tshark -r evidence/pcaps/debian-router_capture_*.pcap

# Filtrar solo Router Advertisements
tshark -r evidence/pcaps/*.pcap -Y "icmpv6.type == 134"

# Filtrar DHCPv6
tshark -r evidence/pcaps/*.pcap -Y "dhcpv6"
```

## Resolución de Problemas

### Problema: No se conecta a IOS

```bash
# Verificar conectividad
ping6 2025:db8:101::1

# Probar SSH manualmente
ssh -v cisco@2025:db8:101::1

# Verificar configuración en ios_config_module
ansible ios-core-router -i inventory/hosts.yml -e 'ansible_python_interpreter=/usr/bin/python3' -m ios_facts
```

### Problema: RADVD no funciona

```bash
# Verificar que radvd está corriendo
systemctl status radvd

# Ver logs
journalctl -u radvd -n 100

# Verificar configuración
radvd -d -C /etc/radvd.conf

# Verificar permisos
ls -la /etc/radvd.conf
```

### Problema: VMs no obtienen dirección IPv6

```bash
# Verificar que el router está enviando RA
tcpdump -i ens160 -n icmp6

# En el host, forzar solicitud de RA
sudo ip -6 addr flush dev ens160
sudo rdisc6 -1 ens160
```

### Problema: DNSmasq no responde

```bash
# Verificar estado
systemctl status dnsmasq

# Ver logs
journalctl -u dnsmasq -n 100

# Probar DNS manualmente
dig @2025:db8:220::1 router.vmware-101001.example.local AAAA
```

## Comandos Útiles

### Limpiar Evidencias

```bash
# Limpiar evidencias anteriores
rm -rf evidence/configs/* evidence/pings/* evidence/pcaps/* evidence/services/*

# O solo logs
rm -f evidence/logs/ansible.log
```

### Re-ejecutar con Limpieza

```bash
# Si quieres empezar de nuevo
ansible-playbook playbooks/site.yml -vvv --flush-cache

# Verificar idempotencia (no debe hacer cambios)
ansible-playbook playbooks/site.yml --check
```

### Debug de Tareas Específicas

```bash
# Ver qué haría sin ejecutar
ansible-playbook playbooks/deploy_all.yml --tags step3 --check

# Ejecutar solo una tarea de un rol
ansible-playbook playbooks/site.yml --tags debian-ipv6-router -e "debug_task=Instalar paquetes"
```

## Próximos Pasos

Después de ejecutar exitosamente:

1. **Revisar evidencias** en `evidence/`
2. **Análizar capturas** con Wireshark
3. **Documentar resultados** para la entrega
4. **Compartir con el profesor** para revisión

## Soporte

Si encuentras problemas:

1. Revisa los logs: `evidence/logs/ansible.log`
2. Ejecuta con `-vvvv` para verbose máximo
3. Consulta la documentación técnica en `docs/CONTEXTO.md`
4. Revisa el troubleshooting en `README.md`

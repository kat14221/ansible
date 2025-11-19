# 🔧 Guía Rápida: Reparar Conectividad IPv6 + Internet

## 🎯 Problemas Identificados

1. ❌ Windows obtiene IP larga con SLAAC (`2025:db8:101:0:7a50:35f0:56b3:2743`)
2. ❌ Clientes no tienen acceso a internet
3. ❌ SSH no funciona a Windows por IP incorrecta

## ✅ Soluciones Implementadas

### Cambios en Archivos

1. **`roles/debian-ipv6-router/templates/radvd.conf.j2`**
   - ✅ Cambio: `AdvAutonomous on` → `AdvAutonomous off`
   - 🎯 Efecto: Deshabilita SLAAC, fuerza DHCPv6 puro

2. **`roles/debian-ipv6-router/templates/nftables.conf.j2`**
   - ✅ Agregado: NAT masquerade para interfaz WAN
   - ✅ Mejorado: Reglas de forward para acceso a internet
   - 🎯 Efecto: Los clientes pueden acceder a internet

3. **`playbooks/configure_academic_lab.yml`**
   - ✅ Agregado: Tareas para deshabilitar SLAAC en Windows
   - ✅ Agregado: Forzar DHCPv6 en adaptador de red
   - 🎯 Efecto: Windows obtendrá IP corta (::11)

4. **`playbooks/fix_network_connectivity.yml`** (NUEVO)
   - 🆕 Playbook para aplicar todas las correcciones
   - 🆕 Diagnóstico automático de conectividad

## 🚀 Ejecución Automática

### Opción 1: Script PowerShell (Recomendado)

```powershell
# Desde PowerShell en Windows
cd d:\ansible
.\scripts\fix_network.ps1
```

### Opción 2: Playbook Ansible Directo

```powershell
# Desde PowerShell
cd d:\ansible
ansible-playbook playbooks/fix_network_connectivity.yml -i inventory/hosts.yml -v
```

## 🔧 Reparación Manual (si Ansible falla)

### En debian-router (SSH)

```bash
# 1. Conectar al router
ssh ansible@172.17.25.122

# 2. Editar radvd
sudo nano /etc/radvd.conf
# Cambiar: AdvAutonomous on → AdvAutonomous off

# 3. Editar nftables
sudo nano /etc/nftables.conf
# Agregar en tabla nat:
# oifname "ens192" masquerade  (ens192 es tu WAN)

# 4. Habilitar forwarding
sudo sysctl -w net.ipv4.ip_forward=1
sudo sysctl -w net.ipv6.conf.all.forwarding=1

# 5. Reiniciar servicios
sudo systemctl restart radvd
sudo systemctl reload nftables

# 6. Verificar
sudo nft list ruleset
ip route show
ip -6 route show
```

### En Windows PC (PowerShell como Administrador)

```powershell
# 1. Deshabilitar SLAAC y forzar DHCPv6
netsh interface ipv6 set interface "Ethernet0" routerdiscovery=disabled
netsh interface ipv6 set interface "Ethernet0" managedaddress=enabled
netsh interface ipv6 set interface "Ethernet0" otherstateful=enabled

# 2. Liberar y renovar IP
ipconfig /release6
Start-Sleep -Seconds 2
ipconfig /renew6

# 3. Verificar nueva configuración
ipconfig /all

# Buscar:
# ✅ Dirección IPv6: 2025:db8:101::11  (IP CORTA)
# ❌ NO: 2025:db8:101:0:xxxx:... (IP LARGA)

# 4. Probar conectividad
ping -6 2025:db8:101::1       # Gateway
ping -6 google.com            # Internet

# 5. Si DHCPv6 no funciona, verificar servicio
Get-Service -Name Dhcp
Start-Service -Name Dhcp
```

### En Ubuntu PC

```bash
# 1. Liberar IP actual
sudo dhclient -6 -r ens192

# 2. Renovar IP vía DHCPv6
sudo dhclient -6 ens192

# 3. Verificar nueva IP
ip -6 addr show ens192
# Deberías ver: 2025:db8:101::10

# 4. Probar conectividad
ping6 -c 3 2025:db8:101::1              # Gateway
ping6 -c 3 2001:4860:4860::8888         # Google DNS
ping6 -c 3 google.com                   # Internet
```

## 🧪 Verificación de Resultados

### Windows debe mostrar:

```
Adaptador de Ethernet Ethernet0:
   Dirección IPv6 . . . . . . . . . : 2025:db8:101::11
   Puerta de enlace predeterminada . : fe80::...
                                       2025:db8:101::1
```

### Ubuntu debe mostrar:

```
inet6 2025:db8:101::10/64 scope global dynamic
```

### debian-router debe tener:

```bash
# nft list ruleset debe mostrar:
table inet nat {
    chain postrouting {
        oifname "ens192" masquerade    # Para WAN
        oifname "ens34" masquerade     # Para LAN
    }
}
```

## 📊 Diagnóstico de Problemas

### Si Windows sigue con IP larga:

```powershell
# Verificar que radvd en debian-router tenga AdvAutonomous off
ssh ansible@172.17.25.122 "cat /etc/radvd.conf | grep AdvAutonomous"
# Debe mostrar: AdvAutonomous off;

# Reiniciar adaptador de red en Windows
Disable-NetAdapter -Name "Ethernet0"
Start-Sleep -Seconds 2
Enable-NetAdapter -Name "Ethernet0"
ipconfig /renew6
```

### Si no hay internet:

```bash
# En debian-router, verificar NAT
sudo nft list table inet nat

# Debe mostrar masquerade para oifname "ens192" (WAN)

# Verificar forwarding
sysctl net.ipv4.ip_forward    # Debe ser: 1
sysctl net.ipv6.conf.all.forwarding  # Debe ser: 1

# Verificar ruta por defecto
ip route show | grep default
# Debe mostrar: default via 172.17.25.253 dev ens192
```

### Si SSH a Windows no funciona:

```powershell
# 1. Verificar que tienes IP corta primero
ipconfig | Select-String "2025:db8:101"

# 2. Verificar que SSH Server está instalado
Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Server*'

# 3. Instalar si es necesario
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

# 4. Iniciar servicio
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'

# 5. Permitir en firewall
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
```

## 📞 Resumen de Comandos Útiles

```powershell
# Windows - Verificación rápida
ipconfig /all
ping -6 2025:db8:101::1
ping -6 google.com
Test-NetConnection -ComputerName "2025:db8:101::1" -Port 22
```

```bash
# Ubuntu - Verificación rápida
ip -6 addr show
ping6 2025:db8:101::1
ping6 google.com
curl -6 http://google.com
```

```bash
# debian-router - Verificación rápida
sudo systemctl status radvd isc-dhcp-server nftables
sudo nft list ruleset
ip -6 route show
cat /var/lib/dhcp/dhcpd6.leases    # Ver leases DHCPv6
```

## ✅ Checklist Final

- [ ] debian-router: AdvAutonomous está en **off**
- [ ] debian-router: NAT masquerade configurado para WAN
- [ ] debian-router: Forwarding IPv4/IPv6 habilitado
- [ ] Windows: IP es **2025:db8:101::11** (sin :0: en el medio)
- [ ] Windows: Puede hacer ping a gateway (::1)
- [ ] Windows: Puede hacer ping a internet (google.com)
- [ ] Ubuntu: IP es **2025:db8:101::10**
- [ ] Ubuntu: Tiene acceso a internet
- [ ] SSH funciona a Windows: `ssh usuario@2025:db8:101::11`

## 🎯 Resultado Esperado

```
✅ Windows: 2025:db8:101::11
✅ Ubuntu: 2025:db8:101::10
✅ Internet: Funcional en ambos
✅ SSH: Accesible por IP corta
✅ DHCPv6: Asignación automática
✅ SLAAC: Deshabilitado
```

---

**Última actualización:** 2025-11-18  
**Versión:** 1.0  
**Estado:** ✅ Correcciones aplicadas

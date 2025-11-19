# 🔧 Solución: Configurar WinRM en Windows + Internet en Ubuntu

## Problema 1: Windows no acepta conexiones de Ansible

### Error:
```
fatal: [windows-pc]: UNREACHABLE! => {"changed": false, "msg": "ssl: HTTPSConnectionPool... Connection refused"}
```

### Solución: Configurar WinRM manualmente en Windows

#### Opción A: Script Automático (Recomendado)

1. **En tu VM Control**, genera el script:
```bash
cd ~/ansible
ansible-playbook playbooks/setup_windows_winrm.yml
```

2. **Copia el script a Windows** (puedes usar USB o compartir carpeta):
```
Archivo generado: setup_winrm_windows.ps1
```

3. **En Windows**, ejecuta como Administrador:
```powershell
PowerShell -ExecutionPolicy Bypass -File setup_winrm_windows.ps1
```

#### Opción B: Comandos Manuales en Windows

Ejecuta en PowerShell como Administrador:

```powershell
# 1. Habilitar WinRM
Enable-PSRemoting -Force

# 2. Configurar autenticación
Set-Item WSMan:\localhost\Service\Auth\Basic $true
Set-Item WSMan:\localhost\Service\AllowUnencrypted $true

# 3. Crear listeners
winrm create winrm/config/Listener?Address=*+Transport=HTTP

$cert = New-SelfSignedCertificate -DnsName "windows-pc" -CertStoreLocation Cert:\LocalMachine\My
New-Item -Path WSMan:\localhost\Listener -Transport HTTPS -Address * -CertificateThumbPrint $cert.Thumbprint -Force

# 4. Abrir firewall
New-NetFirewallRule -DisplayName "WinRM HTTP" -Direction Inbound -LocalPort 5985 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "WinRM HTTPS" -Direction Inbound -LocalPort 5986 -Protocol TCP -Action Allow

# 5. Crear usuario ansible
$password = ConvertTo-SecureString "Ansible123!" -AsPlainText -Force
New-LocalUser -Name "ansible" -Password $password -FullName "Ansible User"
Add-LocalGroupMember -Group "Administrators" -Member "ansible"

# 6. Verificar
winrm get winrm/config
Test-WSMan
```

#### Verificar desde VM Control:
```bash
ansible -i inventory/hosts.yml windows-pc -m win_ping
```

---

## Problema 2: Ubuntu no tiene internet

### Diagnóstico

Ejecuta el playbook de diagnóstico:
```bash
cd ~/ansible
ansible-playbook playbooks/diagnose_internet.yml -i inventory/hosts.yml
```

### Causas Posibles

1. **Ubuntu solo tiene IPv6, pero internet del router es IPv4**
   - Solución: Agregar DHCP IPv4 en Ubuntu

2. **Falta ruta por defecto en Ubuntu**
   - Debe apuntar a debian-router

3. **NAT no está funcionando en debian-router**
   - Verificar nftables masquerade

### Solución: Agregar IPv4 a Ubuntu

Edita el netplan en ubuntu-pc:

```yaml
# /etc/netplan/01-netcfg.yaml
network:
  version: 2
  ethernets:
    ens192:
      dhcp4: yes                # ← AGREGAR ESTO
      dhcp6: yes
      accept-ra: no
      dhcp-identifier: duid
```

Aplicar:
```bash
sudo netplan apply
```

### Verificación

Después de configurar:

```bash
# En ubuntu-pc
ping -c 3 8.8.8.8           # Internet IPv4
ping6 -c 3 google.com       # Internet IPv6
ip route show               # Debe mostrar: default via X.X.X.X dev ens192
```

---

## Checklist de Verificación

### debian-router ✅
- [ ] Forwarding IPv4 habilitado: `sysctl net.ipv4.ip_forward` → `1`
- [ ] Forwarding IPv6 habilitado: `sysctl net.ipv6.conf.all.forwarding` → `1`
- [ ] NAT configurado: `nft list table inet nat` → `masquerade`
- [ ] Tiene internet IPv4: `ping 8.8.8.8` → OK

### ubuntu-pc ✅
- [ ] Tiene IPv4: `ip addr show | grep "inet "`
- [ ] Tiene IPv6: `ip -6 addr show | grep "2025:db8:101"`
- [ ] Ruta por defecto IPv4: `ip route show | grep default`
- [ ] Ruta por defecto IPv6: `ip -6 route show | grep default`
- [ ] Ping a gateway: `ping6 2025:db8:101::1` → OK
- [ ] Ping a internet: `ping 8.8.8.8` → OK

### windows-pc ✅
- [ ] WinRM habilitado: `Test-WSMan` → OK
- [ ] Puerto 5986 abierto en firewall
- [ ] Usuario ansible creado y en grupo Administrators
- [ ] Ansible puede conectar: `ansible windows-pc -m win_ping` → SUCCESS

---

## Orden de Ejecución

1. **Configurar WinRM en Windows** (manual)
2. **Diagnosticar internet:** `ansible-playbook playbooks/diagnose_internet.yml`
3. **Agregar IPv4 a Ubuntu** (si es necesario)
4. **Ejecutar correcciones:** `ansible-playbook playbooks/fix_network_connectivity.yml`

---

## Comandos Rápidos

```bash
# Verificar conectividad
ansible -i inventory/hosts.yml all -m ping

# Diagnosticar problemas
ansible-playbook playbooks/diagnose_internet.yml -i inventory/hosts.yml

# Aplicar correcciones
ansible-playbook playbooks/fix_network_connectivity.yml -i inventory/hosts.yml -v
```

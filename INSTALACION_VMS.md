# 💿 Guía de Instalación Manual de VMs

## 🎯 Configuración Específica para el Proyecto IPv6

Después de ejecutar `ansible-playbook playbooks/create_vms.yml -vvv`, sigue esta guía para instalar manualmente cada VM con la configuración correcta.

## ⚠️ CONFIGURACIÓN CRÍTICA - HOSTNAMES

**IMPORTANTE: Usa estos hostnames exactos durante la instalación:**

| VM | Hostname | Domain |
|----|----------|--------|
| **Debian Router** | `debian-router` | `vmware-101001.local` |
| **Ubuntu PC** | `ubuntu-pc` | `vmware-101001.local` |
| **Windows PC** | `windows-pc` | `VMWARE101001` (workgroup) |

**⭐ Estos nombres son críticos para que Ansible pueda conectarse después.**

---

## 🖥️ VM 1: vm-debian-router (Debian 12)

### **Acceso a la VM:**
1. ESXi Web UI: `https://172.17.25.1/ui/`
2. Buscar VM: `vm-debian-router`
3. Clic derecho → "Open Console"

### **Configuración durante la instalación:**

#### **🌐 Configuración de Red (IMPORTANTE):**

**Durante la instalación, cuando te pida el hostname:**

```
Hostname: debian-router
Domain name: vmware-101001.local
```

- **Hostname**: `debian-router` ⭐ **IMPORTANTE: Usar exactamente este nombre**
- **Domain**: `vmware-101001.local`
- **Interfaz primaria**: ens160 (VM Network)
  - Configurar con DHCP temporalmente
  - IP esperada: 172.17.25.x (se configurará después como .126)

#### **👤 Configuración de Usuarios:**
- **Root password**: `Ansible123!`
- **Usuario principal**: 
  - Nombre completo: `Ansible User`
  - Usuario: `ansible`
  - Contraseña: `Ansible123!`

#### **💾 Particionamiento de Discos (20GB):**
```
Esquema de particiones:
/dev/sda1    512MB   /boot      ext4
/dev/sda2    2GB     swap       swap
/dev/sda3    15GB    /          ext4
/dev/sda4    2.5GB   /home      ext4
```

**Configuración manual:**
1. Seleccionar "Manual" en particionamiento
2. Crear tabla de particiones nueva
3. Crear particiones en este orden:
   - Partición 1: 512MB, primaria, bootable, ext4, punto montaje /boot
   - Partición 2: 2GB, primaria, swap
   - Partición 3: 15GB, primaria, ext4, punto montaje /
   - Partición 4: resto, primaria, ext4, punto montaje /home

#### **📦 Selección de Software:**
- ✅ SSH server
- ✅ Standard system utilities
- ❌ Desktop environment (no instalar)
- ❌ Web server (se instalará con Ansible)

#### **🔧 Configuración Post-Instalación:**
```bash
# Después del primer boot, configurar:

# 1. Configurar sudo sin contraseña
echo 'ansible ALL=(ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/ansible

# 2. Configurar interfaces de red
sudo nano /etc/network/interfaces

# Agregar:
# Interfaz de gestión (ens160)
auto ens160
iface ens160 inet static
address 172.17.25.126
netmask 255.255.255.0
gateway 172.17.25.1
dns-nameservers 8.8.8.8

# Interfaz del proyecto (ens192) - se configurará con Ansible
auto ens192
iface ens192 inet manual

# 3. Reiniciar red
sudo systemctl restart networking

# 4. Verificar SSH
sudo systemctl status ssh
sudo systemctl enable ssh
```

---

## 🖥️ VM 2: vm-ubuntu-pc (Ubuntu 24.04)

### **Acceso a la VM:**
1. ESXi Web UI: `https://172.17.25.1/ui/` → `vm-ubuntu-pc` → "Open Console"

### **Configuración durante la instalación:**

#### **🌐 Configuración de Red (IMPORTANTE):**

**Durante la instalación, cuando te pida el hostname:**

```
Hostname: ubuntu-pc
Domain name: vmware-101001.local
```

- **Hostname**: `ubuntu-pc` ⭐ **IMPORTANTE: Usar exactamente este nombre**
- **Domain**: `vmware-101001.local`
- **Interfaz**: ens160 (Red Fernandez)
  - Configurar con DHCP temporalmente
  - Se configurará IPv6 automáticamente después

#### **👤 Configuración de Usuarios:**
- **Nombre completo**: `Ansible User`
- **Usuario**: `ansible`
- **Contraseña**: `Ansible123!`
- **Iniciar sesión automáticamente**: No
- **Requerir contraseña para iniciar sesión**: Sí

#### **💾 Particionamiento de Discos (25GB):**
```
Esquema de particiones:
/dev/sda1    1GB     /boot/efi  FAT32 (EFI)
/dev/sda2    2GB     swap       swap
/dev/sda3    20GB    /          ext4
/dev/sda4    2GB     /home      ext4
```

**Configuración:**
1. Seleccionar "Custom storage layout"
2. Crear particiones:
   - EFI: 1GB, FAT32, /boot/efi
   - Swap: 2GB
   - Root: 20GB, ext4, /
   - Home: resto, ext4, /home

#### **📦 Selección de Software:**
- ✅ OpenSSH server
- ✅ Basic Ubuntu server
- ❌ Desktop (usar minimal)

#### **🔧 Configuración Post-Instalación:**
```bash
# Después del primer boot:

# 1. Actualizar sistema
sudo apt update && sudo apt upgrade -y

# 2. Configurar sudo (ya debería estar)
sudo usermod -aG sudo ansible

# 3. Verificar SSH
sudo systemctl status ssh
sudo systemctl enable ssh

# 4. Instalar herramientas básicas
sudo apt install -y net-tools iputils-ping curl wget
```

---

## 🖥️ VM 3: vm-windows-pc (Windows 11)

### **Acceso a la VM:**
1. ESXi Web UI: `https://172.17.25.1/ui/` → `vm-windows-pc` → "Open Console"

⚠️ **PROBLEMA DEL MOUSE**: Si el mouse no funciona en la consola web:
- **Solución 1**: Usar VMware Remote Console (VMRC) - Descargar desde ESXi
- **Solución 2**: Navegar con teclado (Tab, Enter, flechas)
- **Solución 3**: Agregar USB Controller manualmente en configuración de VM

### **Configuración durante la instalación:**

#### **🌐 Configuración de Red (IMPORTANTE):**

**Durante la instalación, cuando te pida el nombre del equipo:**

```
Computer name: windows-pc
Workgroup: VMWARE101001
```

- **Hostname**: `windows-pc` ⭐ **IMPORTANTE: Usar exactamente este nombre**
- **Workgroup**: `VMWARE101001`
- **Interfaz**: Ethernet (Red Fernandez)
  - Se configurará automáticamente con IPv6

#### **👤 Configuración de Usuarios:**
- **Usuario local**: `ansible`
- **Contraseña**: `Ansible123!`
- **Preguntas de seguridad**: Configurar según preferencia
- **No usar cuenta Microsoft** (usar cuenta local)

#### **💾 Particionamiento de Discos (40GB):**
```
Esquema de particiones (automático):
C:\ - 40GB (sistema y datos)
```
- Usar particionamiento automático de Windows
- No crear particiones adicionales

#### **📦 Configuración de Windows:**

⚠️ **IMPORTANTE - Saltarse requisitos de TPM:**

Si aparece el error "Este equipo no cumple los requisitos":
1. Presionar **Shift + F10** para abrir CMD
2. Escribir: `regedit` y presionar Enter
3. Navegar a: `HKEY_LOCAL_MACHINE\SYSTEM\Setup`
4. Crear nueva clave: Clic derecho → Nuevo → Clave → Nombrar: `LabConfig`
5. Dentro de `LabConfig`, crear estos valores DWORD (32-bit):
   - `BypassTPMCheck` = `1`
   - `BypassSecureBootCheck` = `1`
   - `BypassRAMCheck` = `1`
6. Cerrar regedit y CMD
7. Clic en "Atrás" y luego "Siguiente" para continuar

**Configuración normal:**
- **Región**: España o tu región
- **Idioma**: Español
- **Teclado**: Español
- **Red**: Configurar como red privada
- **Privacidad**: Configurar según preferencia

#### **🔧 Configuración Post-Instalación:**
```powershell
# Después del primer boot (PowerShell como Administrador):

# 1. Habilitar WinRM para Ansible
Enable-PSRemoting -Force
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force

# 2. Configurar firewall para WinRM
New-NetFirewallRule -DisplayName "WinRM HTTP" -Direction Inbound -Protocol TCP -LocalPort 5985 -Action Allow

# 3. Configurar usuario para WinRM
net localgroup "Remote Management Users" ansible /add

# 4. Verificar configuración IPv6 (después de configurar router)
ipconfig /all
ping -6 2025:db8:101::1
```

---

## 🔧 Verificación Final

### **Después de instalar todas las VMs:**

#### **1. Verificar conectividad SSH (desde tu VM de control):**
```bash
# Probar conexión a debian-router
ssh ansible@172.17.25.126

# Probar conexión a ubuntu-pc (después de configurar IPv6)
ssh ansible@2025:db8:101::10
```

#### **2. Verificar configuración de red:**
```bash
# En debian-router
ip addr show
ip route show

# En ubuntu-pc
ip addr show
ip -6 route show
```

#### **3. Copiar claves SSH:**
```bash
# Desde tu VM de control Ansible
./scripts/copy_ssh_keys.sh
```

---

## 📋 Checklist de Instalación

### **vm-debian-router:**
- [ ] Hostname: `debian-router`
- [ ] Usuario: `ansible` / Password: `Ansible123!`
- [ ] Particiones: /boot (512MB), swap (2GB), / (15GB), /home (2.5GB)
- [ ] SSH habilitado
- [ ] Sudo sin contraseña configurado
- [ ] IP estática: 172.17.25.126/24
- [ ] Gateway: 172.17.25.1

### **vm-ubuntu-pc:**
- [ ] Hostname: `ubuntu-pc`
- [ ] Usuario: `ansible` / Password: `Ansible123!`
- [ ] Particiones: /boot/efi (1GB), swap (2GB), / (20GB), /home (2GB)
- [ ] SSH habilitado
- [ ] Herramientas básicas instaladas

### **vm-windows-pc:**
- [ ] Hostname: `windows-pc`
- [ ] Usuario: `ansible` / Password: `Ansible123!`
- [ ] WinRM habilitado
- [ ] Firewall configurado para WinRM
- [ ] Usuario en grupo "Remote Management Users"

---

## 🚀 Próximo Paso

Una vez completadas todas las instalaciones:

```bash
# Continuar con la configuración automática
ansible-playbook playbooks/site.yml --tags debian,services -vvv
```

---

**⏱️ Tiempo estimado total de instalación manual: 60-90 minutos**  
**🎯 Después de esto, todo será automático con Ansible**
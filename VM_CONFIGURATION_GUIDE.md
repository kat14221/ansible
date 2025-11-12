---
# ============================================================================
# 📋 CONFIGURACIÓN DE VMs CREADAS - Bootstrap Complete
# ============================================================================
# Este archivo contiene toda la información necesaria para configurar
# las VMs creadas por el playbook bootstrap_complete.yml
#
# Fecha de creación: 11/11/2025
# ============================================================================

## 🖥️ VM 1: DEBIAN ROUTER (vm-debian-router)
### Información General:
- **Nombre de VM**: vm-debian-router
- **Sistema Operativo**: Debian 12 (Bookworm)
- **ISO**: [datastore1] debian/debian-12.12.0-amd64-netinst.iso
- **Memoria RAM**: 2048 MB (2 GB)
- **CPUs**: 1
- **Disco duro**: 20 GB (thin provisioned)
- **Folder ESXi**: /vm

### Durante la instalación de Debian:
```
Hostname: debian-router
Domain name: lab.local
```

### Después de instalar el SO:

#### 1️⃣ Crear usuario Ansible:
```bash
sudo adduser ansible
# Contraseña: ansible123
# Nombre completo: Ansible Automation
# Habitación: [Enter]
# Teléfono: [Enter]
# Otro: [Enter]
# ¿Es correcto? Y

# Dar permisos sudo sin contraseña
sudo usermod -aG sudo ansible
echo 'ansible ALL=(ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/ansible
```

#### 2️⃣ Configuración de red:
**Interfaz 1 (WAN - Management)**: ens224
- IP actual: 172.17.25.126 (DHCP)
- Interfaz: VM Network

**Interfaz 2 (LAN)**: ens192
- IP IPv6: 2025:db8:101::1/64
- Interfaz: Red Fernandez

#### 3️⃣ Copiar clave SSH:
```bash
ssh-copy-id ansible@172.17.25.126
# Contraseña: ansible123
```

#### 4️⃣ Credenciales SSH:
- **Usuario**: ansible
- **Contraseña**: ansible123
- **IP (WAN)**: 172.17.25.126
- **IP (LAN IPv6)**: 2025:db8:101::1

---

## 🖥️ VM 2: UBUNTU PC (vm-ubuntu-pc)
### Información General:
- **Nombre de VM**: vm-ubuntu-pc
- **Sistema Operativo**: Ubuntu 24.04 LTS Desktop
- **ISO**: [datastore1] ubuntu/ubuntu-24.04.2-desktop-amd64.iso
- **Memoria RAM**: 2048 MB (2 GB)
- **CPUs**: 1
- **Disco duro**: 20 GB (thin provisioned)
- **Folder ESXi**: /vm

### Durante la instalación de Ubuntu:

#### 1️⃣ Información de instalación:
```
Idioma: Español
Distribución de teclado: Español
```

#### 2️⃣ Conexión de red:
- Seleccionar: "Red Fernandez" (interfaz enp0s17 o similar)
- Puede configurarse con SLAAC (IPv6 automático)

#### 3️⃣ Cuenta de usuario (crear):
```
Nombre completo: Ansible User
Nombre de usuario: ansible
Contraseña: ansible123
Confirmar contraseña: ansible123
```

#### 4️⃣ Seleccionar:
```
☑ Requerir mi contraseña para iniciar sesión
```

#### 5️⃣ Instalación de software:
```
☑ Instalar el sistema de ventanas X.Org
☑ Instalar software estándar del sistema
```

### Después de instalar Ubuntu:

#### 1️⃣ Dar permisos sudo:
```bash
sudo usermod -aG sudo ansible
echo 'ansible ALL=(ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/ansible
```

#### 2️⃣ Configuración de red:
**Interfaz**: enp0s17 (Red Fernandez)
- Método: SLAAC (IPv6 automático desde Debian Router)
- IP IPv6 esperada: 2025:db8:101::50/64

#### 3️⃣ Copiar clave SSH:
```bash
ssh-copy-id ansible@2025:db8:101::50
# Contraseña: ansible123
```

#### 4️⃣ Credenciales SSH:
- **Usuario**: ansible
- **Contraseña**: ansible123
- **IP (IPv6)**: 2025:db8:101::10
- **Hostname**: ubuntu-pc (cambiar después con: hostnamectl set-hostname ubuntu-pc)

---

## 🖥️ VM 3: WINDOWS PC (vm-windows-pc)
### Información General:
- **Nombre de VM**: vm-windows-pc
- **Sistema Operativo**: Windows 11 (25H2 Spanish Mexico)
- **ISO**: [datastore1] W-11/Win11_25H2_Spanish_Mexico_x64.iso
- **Memoria RAM**: 8192 MB (8 GB)
- **CPUs**: 4
- **Disco duro**: 40 GB (thin provisioned)
- **Folder ESXi**: /vm
- **Boot Mode**: EFI

### Durante la instalación de Windows:

#### 1️⃣ Selecciones iniciales:
```
Idioma: Español (España)
Formato de hora y moneda: Español (España)
Teclado: Español
```

#### 2️⃣ Instalación:
```
Seleccionar: "Windows 11 Pro"
Tipo de instalación: Instalación personalizada
Seleccionar todo el espacio disponible para particionar
```

#### 3️⃣ Crear cuenta de usuario:
```
Nombre del equipo: windows-pc
```

#### 4️⃣ Cuenta de usuario:
```
Nombre de usuario: Administrator
Contraseña: Ansible123!
Confirmar: Ansible123!
```

#### 5️⃣ Configuración de privacidad:
```
Desactivar todas las opciones de recopilación de datos
```

### Después de instalar Windows:

#### 1️⃣ Configurar red:
**Interfaz**: Ethernet (Red Fernandez)
- Obtener IPv6 automáticamente (SLAAC desde Debian Router)
- IP IPv6 esperada: 2025:db8:101::11/64

#### 2️⃣ Instalar Windows Terminal (opcional pero recomendado):
```powershell
# Desde Microsoft Store
```

#### 3️⃣ Credenciales WinRM:
- **Usuario**: Administrator
- **Contraseña**: Ansible123!
- **IP (IPv6)**: 2025:db8:101::11
- **Protocolo**: WinRM (Puerto 5985 HTTP)

---

## 📊 TABLA RESUMEN

| Componente | debian-router | ubuntu-pc | windows-pc |
|-----------|---------------|-----------|-----------|
| **Hostname** | debian-router | ubuntu-pc | windows-pc |
| **SO** | Debian 12 | Ubuntu 24.04 LTS | Windows 11 |
| **Usuario** | ansible | ansible | Administrator |
| **Contraseña** | ansible123 | ansible123 | Ansible123! |
| **RAM** | 2 GB | 2 GB | 8 GB |
| **CPUs** | 1 | 1 | 4 |
| **Disco** | 20 GB | 20 GB | 40 GB |
| **IP WAN/IPv4** | 172.17.25.126 | N/A | N/A |
| **IP LAN IPv6** | 2025:db8:101::1 | 2025:db8:101::10 | 2025:db8:101::11 |
| **Red LAN** | Red Fernandez | Red Fernandez | Red Fernandez |

---

## 🔌 PASOS GENERALES DE CONFIGURACIÓN

### Para todas las VMs Linux:

1. **Instalar con el SO**
2. **Crear usuario ansible con contraseña ansible123**
3. **Dar permisos sudo sin contraseña**:
   ```bash
   sudo usermod -aG sudo ansible
   echo 'ansible ALL=(ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/ansible
   ```
4. **Copiar clave SSH desde la máquina control**:
   ```bash
   ssh-copy-id ansible@<IP_VM>
   ```

### Para Windows:

1. **Instalar con el SO**
2. **Usuario Administrator con contraseña Ansible123!**
3. **Habilitar WinRM** (opcional para automatización):
   ```powershell
   Enable-PSRemoting -Force
   Set-Item wsman:\localhost\client\trustedhosts -Value "*" -Force
   ```

---

## 🚀 PRÓXIMOS PASOS

Una vez configuradas todas las VMs:

1. Ejecutar el playbook de validación:
   ```bash
   ansible-playbook playbooks/validate_connectivity.yml -i inventory/hosts.yml
   ```

2. Ejecutar la configuración completa:
   ```bash
   ansible-playbook playbooks/site.yml -i inventory/hosts.yml --ask-vault-pass
   ```

---

## 📝 NOTAS IMPORTANTES

- ⚠️ **Las contraseñas mostradas son para laboratorio** - NO usar en producción
- ⚠️ **El Debian Router es crítico** - Configúralo primero
- ⚠️ **IPv6 depende del Debian Router** - Debe estar corriendo radvd
- ⚠️ **Windows necesita conectividad de red** - Verificar con `ipv6 /all`
- ⚠️ **Cambiar contraseñas después** - Para ambiente de producción

---

Última actualización: 11/11/2025
Creado por: Ansible Bootstrap Script

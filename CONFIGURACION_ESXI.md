# Configuración del ESXi Host - VMWARE-101001

## Información del ESXi

### Acceso
- **URL**: `https://168.121.48.254:10101/ui/#/login`
- **Host**: `168.121.48.254:443`
- **Usuario**: `root`
- **Contraseña**: `qwe123$`

---

## Configuración Simplificada

### Port Group Principal: **VM Network**
- **vSwitch**: vSwitch0
- **VLAN ID**: 0
- **Uso**: Todas las VMs se conectarán a este Port Group
- **Adaptador físico**: Se configurará manualmente después de levantar las VMs

### Datastore: **datastore1**
- Contenido visible: ubuntu, debian, W_Server2022, W-11

---

## Configuración de VMs

### 1. VM Debian Router
- **Template**: "Debian 12 Template" (o nombre exacto del template)
- **IP LAN**: 2025:db8:220::1/64
- **Port Group**: VM Network

### 2. VM Ubuntu PC
- **Template**: "Ubuntu 22.04 Template" (o nombre exacto del template)
- **IP LAN**: 2025:db8:220::10/64 (SLAAC)
- **Port Group**: VM Network

### 3. VM Windows PC
- **Template**: "Windows Server 2022 Template" (o nombre exacto del template)
- **IP LAN**: 2025:db8:220::11/64 (SLAAC)
- **Port Group**: VM Network

---

## Información Requerida

Para completar la configuración, necesito:

### Templates o ISOs

**Opción A: Si existen templates** (recomendado):
- [ ] Nombre exacto del template de Debian
- [ ] Nombre exacto del template de Ubuntu
- [ ] Nombre exacto del template de Windows

**Opción B: Si se usan ISOs**:
- [ ] Nombre exacto del ISO de Debian (ej: `debian-12.iso`)
- [ ] Nombre exacto del ISO de Ubuntu (ej: `ubuntu-22.04.iso`)
- [ ] Nombre exacto del ISO de Windows (ej: `Windows-Server-2022.iso`)

---

## Pasos de Ejecución

### 1. Antes de Ejecutar Ansible
- ✅ Configurar VM de control dentro del ESXi
- ✅ Instalar Ansible y collections
- ✅ Transferir este proyecto a la VM de control
- ⏳ Confirmar nombres exactos de templates/ISOs
- ⏳ Actualizar `inventory/hosts.yml` con nombres exactos

### 2. Ejecutar Ansible
```bash
# Crear las VMs
ansible-playbook playbooks/site.yml -vvv
```

### 3. Después de Crear las VMs
- ⚙️ Configurar adaptador físico al vSwitch manualmente
- ⚙️ Conectar el switch físico al backbone IPv6
- ⚙️ Verificar conectividad

---

## Nota Importante

**No se creará configuración de red adicional automáticamente.**

La configuración del adaptador físico del vSwitch al switch físico se hará **manualmente** después de levantar las VMs. Ansible solo se encargará de:
1. Crear las VMs
2. Asignar direcciones IPv6
3. Configurar servicios (RADVD, DNSmasq, Apache)
4. Ejecutar tests básicos de conectividad

La conexión al backbone IPv6 se completará manualmente conectando el adaptador físico al switch real.

---

## Resumen de Configuración

- **Port Group**: VM Network
- **vSwitch**: vSwitch0
- **Datastore**: datastore1
- **Red IPv6 LAN**: 2025:db8:220::/64
- **Adaptador físico**: Configuración manual posterior

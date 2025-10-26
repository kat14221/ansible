# Resumen de Configuración - VMWARE-101001

## ✅ Configuración Confirmada

### Red: **Red Fernandez**
- **Port Group**: Red Fernandez
- **vSwitch**: Fernandez1
- **VLAN ID**: 0
- **IP LAN**: 2025:db8:220::/64
- **Adaptador físico**: Se agregará manualmente DESPUÉS

### VMs - Todas en Red Fernandez

#### 1. vm-debian-router
- **IP**: 2025:db8:220::1/64 (static)
- **Función**: Gateway LAN
- **Servicios**: RADVD, DNSmasq, Apache
- **ISO**: `datastore1:debian/debian-12.12.0-amd64-netinst.iso`

#### 2. vm-ubuntu-pc
- **IP**: 2025:db8:220::10/64 (SLAAC)
- **ISO**: `datastore1:ubuntu/ubuntu-24.04.2-desktop-amd64.iso`

#### 3. vm-windows-pc
- **IP**: 2025:db8:220::11/64 (SLAAC)
- **ISO**: `datastore1:W-11/Win11_24H2_Spanish_x64.iso`

### Datastore
- **Nombre**: datastore1

---

## ✅ Configuración Completa

### ISOs Configuradas
- ✅ Debian: `datastore1:debian/debian-12.12.0-amd64-netinst.iso`
- ✅ Ubuntu: `datastore1:ubuntu/ubuntu-24.04.2-desktop-amd64.iso`
- ✅ Windows: `datastore1:W-11/Win11_24H2_Spanish_x64.iso`

---

## 🚀 Ejecución

```bash
# 1. Transferir proyecto a VM de control en ESXi
# 2. Ejecutar:
ansible-playbook playbooks/site.yml -vvv

# 3. DESPUÉS: Agregar adaptador físico a Red Fernandez manualmente
```

---

## 📝 Notas Importantes

### Configuración de Red
- ✅ **Red Fernandez**: Única red para todas las VMs
- ⚙️ **Adaptador físico**: Se agregará manualmente DESPUÉS
- ⚙️ **Configuración NIC física**: Manual en la interfaz web del ESXi

### Pasos Manuales Posteriores
1. ✅ Ansible crea las VMs en Red Fernandez
2. ⚙️ Entrar en "Red Fernandez" en el ESXi
3. ⚙️ Agregar adaptador físico al vSwitch "Fernandez1"
4. ⚙️ Conectar NIC física al switch físico del backbone
5. ⚙️ Verificar conectividad IPv6

---

## Diagrama de Red

```
Red Fernandez (Fernandez1, VLAN 0)
├── vm-debian-router (2025:db8:220::1/64) ← GATEWAY
├── vm-ubuntu-pc (2025:db8:220::10/64)
├── vm-windows-pc (2025:db8:220::11/64)
└── [ADAPTADOR FÍSICO] ← Se agregará manualmente
    └── Backbone IPv6 (2025:db8:101::/64)
```

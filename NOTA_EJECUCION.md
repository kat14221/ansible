# ⚠️ IMPORTANTE: Instrucciones de Ejecución

## Ubicación del Proyecto

Este proyecto debe ejecutarse desde **dentro del ESXi**, específicamente desde una **VM creada dentro del propio ESXi**.

### ¿Por qué?
- Políticas de red académica bloquean el acceso desde tu máquina local
- Solo puedes acceder al ESXi vía web: `https://168.121.48.254:10101/ui/#/login`
- La automatización debe ejecutarse desde una VM dentro del ESXi que tenga acceso a la red

## Pasos de Ejecución

### 1. Acceder al ESXi
```
URL: https://168.121.48.254:10101/ui/#/login
Usuario: root
Contraseña: qwe123$
```

### 2. Crear una VM de Control (Si no existe)
Necesitas una VM dentro del ESXi que:
- Tenga conectividad de red IPv6
- Tenga Ansible instalado
- Tenga acceso SSH al ESXi y a las VMs que se crearán
- Pueda clonar este repositorio

### 3. Clonar/Transferir el Proyecto
```bash
# Opción A: Clonar desde Git
git clone <url-del-repositorio>

# Opción B: Transferir archivos vía SCP/SFTP
scp -r ansible-debian/ ansible@VM-Control:~/proyecto/
```

### 4. Configurar Ansible en la VM de Control
```bash
# Instalar Ansible
sudo apt update
sudo apt install -y ansible python3-pip

# Instalar collections necesarias
ansible-galaxy collection install cisco.ios community.vmware ansible.netcommon

# Instalar dependencias
pip3 install pyvmomi netaddr jmespath
```

### 5. Verificar Credenciales
El archivo `inventory/hosts.yml` ya está configurado con:
- **ESXi Host**: 168.121.48.254:443
- **Usuario**: root
- **Contraseña**: qwe123$

### 6. Ejecutar el Proyecto
```bash
cd ansible-debian

# Verificar inventario
ansible-inventory -i inventory/hosts.yml --list

# Ejecutar completo
ansible-playbook playbooks/site.yml -vvv

# O por pasos
ansible-playbook playbooks/deploy_all.yml --tags step1
ansible-playbook playbooks/deploy_all.yml --tags step2
ansible-playbook playbooks/deploy_all.yml --tags step3
ansible-playbook playbooks/deploy_all.yml --tags step4
```

## Consideraciones Importantes

### Conectividad de Red
- La VM de control debe tener acceso IPv6 al backbone (2025:DB8:101::/64)
- Debe poder comunicarse con el ESXi en 168.121.48.254
- Debe poder acceder a las VMs creadas después del despliegue

### Acceso al ESXi
- El ESXi está en: `168.121.48.254:443`
- Usuario: `root`
- Contraseña: `qwe123$`
- Acceso web: `https://168.121.48.254:10101/ui/#/login`

### Políticas de Red
- Tu máquina local NO puede acceder directamente
- DEBES ejecutar desde dentro del ESXi (en una VM)
- Solo acceso permitido vía interfaz web del ESXi

## Estructura de Acceso

```
┌─────────────────────────────────────────┐
│ Tu Máquina Local                        │
│ (NO tiene acceso a red IPv6)            │
│                                         │
│ Acceso web: https://168.121.48.254     │
└──────────────┬──────────────────────────┘
               │ HTTPS Web UI
               │ Puerto 10101
               ↓
┌─────────────────────────────────────────┐
│ ESXi Host (168.121.48.254)             │
│                                         │
│  ┌──────────────────────────────────┐  │
│  │ VM de Control                    │  │
│  │ (Aquí ejecutas Ansible)          │  │
│  │ - Tiene Ansible instalado        │  │
│  │ - Clonó este proyecto            │  │
│  │ - Puede acceder a red IPv6       │  │
│  │ - Ejecuta los playbooks          │  │
│  └──────────────────────────────────┘  │
│                                         │
│  Las VMs creadas por Ansible:          │
│  - vm-debian-router                    │
│  - vm-ubuntu-pc                        │
│  - vm-windows-pc                       │
└─────────────────────────────────────────┘
               │
               │ Red Backbone IPv6
               │ 2025:DB8:101::/64
               ↓
┌─────────────────────────────────────────┐
│ Red Académica                           │
│ Routers y Switches Cisco IOS            │
└─────────────────────────────────────────┘
```

## Checklist de Preparación

Antes de ejecutar, verifica:

- [ ] Tienes acceso al ESXi vía web
- [ ] Creaste/identificaste una VM de control en el ESXi
- [ ] Tienes acceso SSH a la VM de control
- [ ] Instalaste Ansible en la VM de control
- [ ] Instalaste las collections necesarias
- [ ] Transferiste/clonaste este proyecto a la VM de control
- [ ] Verificaste que `inventory/hosts.yml` está configurado correctamente
- [ ] Tienes conectividad de red desde la VM de control

## Solución de Problemas

### Error: No se puede conectar al ESXi
- Verifica la IP: `168.121.48.254:443`
- Verifica credenciales: `root / qwe123$`
- Verifica conectividad desde la VM de control

### Error: No se pueden crear las VMs
- Verifica que los templates existen en el ESXi
- Verifica permisos del usuario `root`
- Verifica espacio en el datastore

### Error: No hay conectividad IPv6
- Verifica que la VM de control tiene IPv6 configurado
- Verifica que el backbone está accesible
- Verifica firewall y ACLs

## Resumen

✅ **Ejecuta este proyecto desde UNA VM DENTRO del ESXi**  
✅ **NO lo ejecutes desde tu máquina local**  
✅ **El ESXi está en: 168.121.48.254**  
✅ **Credenciales: root / qwe123$**  
✅ **URL Web: https://168.121.48.254:10101/ui/#/login**


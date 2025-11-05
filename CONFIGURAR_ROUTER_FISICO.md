# 🔧 Configurar Router Físico Cisco para Ansible

## 📋 Requisitos

Tu router físico actualmente **NO** tiene credenciales configuradas (acceso libre por consola).

**Ansible NO puede usar cable de consola**, necesita conectarse por **SSH**, que requiere:
1. ✅ Usuario y contraseña
2. ✅ SSH habilitado
3. ✅ IP de gestión accesible

---

## 🚀 Configuración Rápida (5 minutos)

### **Paso 1: Conectar por Consola (Putty)**

1. Conecta cable de consola al router
2. Abre Putty:
   - **Connection type:** Serial
   - **Serial line:** COM3 (o el puerto que corresponda)
   - **Speed:** 9600
3. Click **Open**

---

### **Paso 2: Configurar Usuario y SSH**

```cisco
! Entrar a modo privilegiado
enable

! Entrar a configuración
configure terminal

! ============================================
! PASO 1: Crear usuario para Ansible
! ============================================
username admin privilege 15 secret Cisco123!

! ============================================
! PASO 2: Configurar nombre de dominio (necesario para SSH)
! ============================================
ip domain-name laboratorio.local

! ============================================
! PASO 3: Generar llaves RSA para SSH
! ============================================
crypto key generate rsa modulus 2048
! Cuando pregunte, confirmar con "yes"

! ============================================
! PASO 4: Habilitar SSH versión 2
! ============================================
ip ssh version 2
ip ssh time-out 60
ip ssh authentication-retries 3

! ============================================
! PASO 5: Configurar acceso remoto (vty lines)
! ============================================
line vty 0 4
 login local
 transport input ssh
 exit

! ============================================
! PASO 6: Configurar IP de gestión (si no la tiene)
! ============================================
! Ejemplo: usar interfaz GigabitEthernet0/2 para gestión
interface GigabitEthernet0/2
 description Management Interface
 ip address 192.168.1.1 255.255.255.0
 no shutdown
 exit

! ============================================
! PASO 7: Guardar configuración
! ============================================
end
write memory
! o
copy running-config startup-config
```

---

### **Paso 3: Verificar Configuración**

```cisco
! Ver configuración SSH
show ip ssh

! Salida esperada:
! SSH Enabled - version 2.0
! ...

! Ver usuarios configurados
show run | include username

! Salida esperada:
! username admin privilege 15 secret ...

! Ver interfaces con IP
show ip interface brief

! Salida esperada:
! GigabitEthernet0/2    192.168.1.1    YES manual up    up
```

---

### **Paso 4: Probar Conexión SSH**

Desde tu PC o VM de control:

```bash
# Probar SSH al router
ssh admin@192.168.1.1

# Te pedirá:
# Password: Cisco123!

# Si conecta exitosamente, verás:
Router>
```

---

## 🔐 Credenciales Configuradas

Después de estos pasos, tendrás:

| Parámetro | Valor |
|-----------|-------|
| **Usuario** | `admin` |
| **Contraseña** | `Cisco123!` |
| **IP Gestión** | `192.168.1.1` (ajustar según tu red) |
| **Protocolo** | SSH v2 |
| **Privilegios** | 15 (acceso total) |

---

## 📝 Actualizar Ansible

### **1. Actualizar Vault con Credenciales:**

```bash
# Editar Vault
ansible-vault edit group_vars/all/vault.yml

# Cambiar:
vault_cisco_user: "admin"
vault_cisco_password: "Cisco123!"
```

### **2. Actualizar Inventario con IP de Gestión:**

```bash
vim inventory/hosts.yml

# Línea 121 (physical-router):
ansible_host: "192.168.1.1"  # Tu IP de gestión real
```

### **3. Probar Conexión desde Ansible:**

```bash
# Test de conectividad
ansible physical-router -m ios_command -a "commands='show version'"

# Si funciona, verás la versión de IOS
```

---

## 🔄 Alternativa: Usar Telnet (NO Recomendado)

Si tienes problemas con SSH, puedes usar Telnet **temporalmente**:

```cisco
! Habilitar Telnet
line vty 0 4
 login local
 transport input telnet ssh
 exit

write memory
```

En el inventario:
```yaml
ansible_connection: network_cli
ansible_network_os: ios
ansible_port: 23  # Telnet
```

**⚠️ Telnet NO es seguro. Úsalo solo para pruebas.**

---

## 🆘 Troubleshooting

### **Error: "% No password set"**
```cisco
! Verificar que el usuario tiene password
show run | include username

! Si no aparece, crearlo:
configure terminal
username admin privilege 15 secret Cisco123!
end
write memory
```

### **Error: "% SSH not enabled"**
```cisco
! Verificar dominio
show run | include domain-name

! Si no está, configurarlo:
configure terminal
ip domain-name laboratorio.local
crypto key generate rsa modulus 2048
end
```

### **Error: "Connection refused"**
```bash
# Verificar que SSH está habilitado
ssh admin@192.168.1.1

# Si falla, verificar en el router:
show ip ssh
show line vty 0 4
```

### **Error: "No route to host"**
```bash
# Verificar conectividad IP
ping 192.168.1.1

# Si no responde:
# 1. Verificar IP de gestión en el router
# 2. Verificar cable conectado
# 3. Verificar VLAN/switch intermedio
```

---

## 📊 Resumen del Flujo

```
┌─────────────────────────────────────┐
│  1. Conectar por Consola (libre)    │
│     Putty + Cable Serial            │
└───────────────┬─────────────────────┘
                │
                ▼
┌─────────────────────────────────────┐
│  2. Configurar Usuario              │
│     username admin secret Cisco123! │
└───────────────┬─────────────────────┘
                │
                ▼
┌─────────────────────────────────────┐
│  3. Habilitar SSH                   │
│     crypto key generate rsa         │
└───────────────┬─────────────────────┘
                │
                ▼
┌─────────────────────────────────────┐
│  4. Configurar IP de Gestión        │
│     interface Gig0/2: 192.168.1.1   │
└───────────────┬─────────────────────┘
                │
                ▼
┌─────────────────────────────────────┐
│  5. Guardar Config                  │
│     write memory                    │
└───────────────┬─────────────────────┘
                │
                ▼
┌─────────────────────────────────────┐
│  6. Probar SSH                      │
│     ssh admin@192.168.1.1           │
└───────────────┬─────────────────────┘
                │
                ▼
┌─────────────────────────────────────┐
│  7. Ansible puede conectarse ✅     │
│     ansible physical-router -m ping │
└─────────────────────────────────────┘
```

---

## ✅ Checklist

- [ ] Conectado por consola a router físico
- [ ] Usuario `admin` creado con contraseña
- [ ] SSH habilitado (versión 2)
- [ ] Llaves RSA generadas
- [ ] IP de gestión configurada
- [ ] Configuración guardada (`write memory`)
- [ ] SSH probado desde PC/VM
- [ ] Vault de Ansible actualizado con credenciales
- [ ] Inventario actualizado con IP de gestión
- [ ] Test de Ansible exitoso

---

**Una vez completado, ejecuta:**
```bash
./scripts/setup_vault.sh  # Ahora con credenciales reales
ansible-playbook playbooks/site.yml --tags network
```

🚀 **¡Tu router estará listo para Ansible!**

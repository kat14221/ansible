# 🚀 Setup Automatizado - 3 Comandos

## ✨ Todo en 3 pasos (Automatizado)

```bash
# Paso 1: Bootstrap (instala dependencias)
./bootstrap_control_vm.sh && ansible-playbook playbooks/bootstrap_control.yml

# Paso 2: Configurar Vault y SSH (interactivo)
chmod +x scripts/*.sh && ./scripts/quick_setup.sh

# Paso 3: Ejecutar proyecto
ansible-playbook playbooks/site.yml
```

---

## 📋 Flujo Completo

```
┌─────────────────────────────────────────┐
│  1. VM de Control (Debian/Ubuntu)       │
│     Usuario: ansible                    │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  2. Bootstrap                           │
│  ./bootstrap_control_vm.sh              │
│  ✅ Instala Python, Ansible, collections│
│  ✅ Crea directorios                    │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  3. Post-Bootstrap                      │
│  ansible-playbook                       │
│      playbooks/bootstrap_control.yml    │
│  ✅ Genera clave SSH                    │
│  ✅ Configura ansible.cfg               │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  4. Setup Automático 🆕                 │
│  ./scripts/quick_setup.sh               │
│  ✅ Pide credenciales ESXi              │
│  ✅ Pide credenciales Cisco             │
│  ✅ Crea y cifra vault.yml              │
│  ✅ Guarda .vault_pass                  │
│  ✅ Copia claves SSH (opcional)         │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  5. Ejecutar Proyecto                   │
│  ansible-playbook playbooks/site.yml    │
│  ✅ Configura physical-router           │
│  ✅ Crea VMs en ESXi                    │
│  ✅ Configura debian-router             │
│  ✅ Aplica firewall + hardening         │
│  ✅ Genera evidencias e informes        │
└─────────────────────────────────────────┘
```

---

## 🛠️ Scripts Disponibles

### **1. setup_vault.sh** - Configurar Vault
```bash
./scripts/setup_vault.sh
```
- Te pide credenciales interactivamente
- Crea `group_vars/all/vault.yml`
- Cifra automáticamente con Ansible Vault
- Guarda password en `.vault_pass`

---

### **2. copy_ssh_keys.sh** - Copiar Claves SSH
```bash
./scripts/copy_ssh_keys.sh
```
- Detecta tu clave SSH automáticamente
- Lista todos los hosts
- Copia la clave a cada host
- Muestra resumen de éxitos/fallos

---

### **3. quick_setup.sh** - Setup Completo (Maestro)
```bash
./scripts/quick_setup.sh
```
- Verifica bootstrap ejecutado
- Ejecuta `setup_vault.sh`
- Permite editar inventario
- Ejecuta `copy_ssh_keys.sh` (opcional)
- Muestra siguientes pasos

---

## 🎯 Ejemplos de Uso

### **Primera Vez (desde cero):**
```bash
# 1. Clonar proyecto
git clone https://github.com/kat14221/ansible.git
cd ansible

# 2. Bootstrap
./bootstrap_control_vm.sh
ansible-playbook playbooks/bootstrap_control.yml

# 3. Setup automático (pide credenciales)
chmod +x scripts/*.sh
./scripts/quick_setup.sh

# 4. Ejecutar
ansible-playbook playbooks/site.yml
```

### **Re-configurar Vault (cambiar credenciales):**
```bash
# Eliminar vault anterior
rm -f group_vars/all/vault.yml .vault_pass

# Crear nuevo
./scripts/setup_vault.sh
```

### **Solo Copiar Claves SSH:**
```bash
./scripts/copy_ssh_keys.sh
```

---

## ✅ Ventajas del Setup Automatizado

| Antes (Manual) | Ahora (Automatizado) |
|----------------|---------------------|
| Copiar template | ❌ No necesario |
| Editar vault.yml | ❌ No necesario |
| Cifrar manualmente | ❌ No necesario |
| Crear .vault_pass | ❌ No necesario |
| Copiar SSH key manualmente | ❌ No necesario |
| **Tiempo total:** ~15 min | **Tiempo total:** ~5 min ⚡ |
| **Pasos manuales:** 8 | **Pasos manuales:** 1 🎯 |
| **Errores comunes:** Muchos | **Errores comunes:** Casi ninguno ✅ |

---

## 🔐 Seguridad

### **Archivos Sensibles (NO commitear):**
```bash
.vault_pass           # Contraseña del Vault
group_vars/all/vault.yml  # Credenciales (cifrado, pero no commitear)
```

### **¿Qué SÍ está en Git?**
```bash
group_vars/all/vault.yml.template  # Template vacío
scripts/setup_vault.sh             # Script de configuración
scripts/copy_ssh_keys.sh           # Script de copia de claves
scripts/quick_setup.sh             # Script maestro
```

### **Ver/Editar Vault Cifrado:**
```bash
# Ver contenido
ansible-vault view group_vars/all/vault.yml

# Editar (pide contraseña)
ansible-vault edit group_vars/all/vault.yml

# Cambiar contraseña
ansible-vault rekey group_vars/all/vault.yml
```

---

## 📊 Resumen Visual

```
       🖥️ VM Control
          │
          ▼
    📦 Bootstrap
    ./bootstrap_control_vm.sh
          │
          ▼
    🔧 Post-Bootstrap
    ansible-playbook bootstrap_control.yml
          │
          ▼
    🚀 Setup Automático (NUEVO)
    ./scripts/quick_setup.sh
          │
          ├─➤ 🔐 Pide credenciales ESXi
          ├─➤ 🔐 Pide credenciales Cisco
          ├─➤ 🔑 Pide password Vault
          ├─➤ ✅ Crea vault.yml cifrado
          ├─➤ ✅ Guarda .vault_pass
          └─➤ 🔑 Copia SSH keys (opcional)
          │
          ▼
    🎯 Ejecutar Proyecto
    ansible-playbook playbooks/site.yml
          │
          ▼
    ✅ PROYECTO DESPLEGADO
```

---

## 🆘 Troubleshooting

### **Error: "vault.yml already exists"**
```bash
# Opción 1: Eliminar y recrear
rm -f group_vars/all/vault.yml .vault_pass
./scripts/setup_vault.sh

# Opción 2: Editar existente
ansible-vault edit group_vars/all/vault.yml
```

### **Error: "No se encuentra clave SSH"**
```bash
# Generar nueva clave
ansible-playbook playbooks/bootstrap_control.yml

# Verificar
ls -la ~/.ssh/id_rsa_ansible*
```

### **Error al copiar SSH keys**
```bash
# Verificar que hosts estén disponibles
ping 172.17.25.126

# Copiar manualmente
ssh-copy-id -i ~/.ssh/id_rsa_ansible.pub ansible@172.17.25.126
```

---

## 🎓 Próximos Pasos

Después del setup automatizado:

1. ✅ **Ajustar IPs** en `inventory/hosts.yml`
2. ✅ **Crear VMs** manualmente si no existen
3. ✅ **Instalar OS** en las VMs
4. ✅ **Copiar SSH keys** a las VMs
5. ✅ **Ejecutar:** `ansible-playbook playbooks/site.yml`

---

**¿Tienes sugerencias? Abre un issue en el repo. 🚀**

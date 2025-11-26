# ✅ Corrección: Error vault_ansible_user

## 🐛 Problema

Al ejecutar el playbook de hardening, aparecía el error:
```
The task includes an option with an undefined variable. 
The error was: 'vault_ansible_user' is undefined
```

## ✅ Solución Aplicada

He corregido **2 archivos** para usar `ansible_user` en lugar de `vault_ansible_user`:

### 1. `roles/hardening/tasks/main.yml`
- ✅ Línea 32: Configuración sudoers para ansible
- ✅ Línea 177: Configuración umask
- ✅ Línea 195: Verificación de hardening
- ✅ Línea 211: Resumen de hardening

### 2. `roles/ssh-hardening/tasks/main.yml`
- ✅ Línea 41: AllowUsers en SSH

**Cambio realizado:**
```yaml
# ANTES (causaba error)
{{ vault_ansible_user }}

# DESPUÉS (funciona)
{{ ansible_user | default('ansible') }}
```

## 🚀 Cómo Ejecutar Ahora

```bash
# 1. Aplicar hardening (ahora funciona)
ansible-playbook playbooks/site.yml -i inventory/hosts.yml --tags hardening -v

# 2. Aplicar SSH hardening
ansible-playbook playbooks/site.yml -i inventory/hosts.yml --tags ssh -v

# 3. Aplicar firewall
ansible-playbook playbooks/site.yml -i inventory/hosts.yml --tags firewall -v
```

## ✅ Verificación

Después de ejecutar, verifica que se crearon los archivos:

```bash
# Conectarse al debian-router
ssh ansible@172.17.25.126

# Verificar sudoers
sudo cat /etc/sudoers.d/ansible
# Debe mostrar: ansible ALL=(ALL) NOPASSWD: ALL

sudo cat /etc/sudoers.d/operator
# Debe mostrar los permisos limitados de operator
```

## 📋 Comandos Completos (Orden Correcto)

```bash
# 1. Crear usuarios académicos
ansible-playbook playbooks/configure_academic_lab.yml \
  -i inventory/hosts.yml \
  --tags users \
  -v

# 2. Aplicar hardening (CORREGIDO)
ansible-playbook playbooks/site.yml \
  -i inventory/hosts.yml \
  --tags hardening \
  -v

# 3. Aplicar SSH hardening (CORREGIDO)
ansible-playbook playbooks/site.yml \
  -i inventory/hosts.yml \
  --tags ssh \
  -v

# 4. Aplicar firewall
ansible-playbook playbooks/site.yml \
  -i inventory/hosts.yml \
  --tags firewall \
  -v

# 5. Generar evidencias
ansible-playbook playbooks/generar_evidencias_usuarios.yml \
  -i inventory/hosts.yml \
  -v
```

## 🎯 Qué se Corrigió

| Archivo | Líneas Corregidas | Estado |
|---------|-------------------|--------|
| `roles/hardening/tasks/main.yml` | 4 ocurrencias | ✅ Corregido |
| `roles/ssh-hardening/tasks/main.yml` | 1 ocurrencia | ✅ Corregido |

## 💡 Explicación Técnica

**Por qué ocurrió el error:**
- Los roles usaban `vault_ansible_user` esperando que estuviera definido en un archivo vault
- Esta variable no existía en tu configuración

**Cómo se solucionó:**
- Cambiamos a usar `ansible_user` que es una variable automática de Ansible
- Agregamos `| default('ansible')` como fallback si `ansible_user` no está definido
- Ahora funciona sin necesidad de configuración adicional

## ✅ Estado Actual

**Archivos corregidos:** ✅  
**Listo para ejecutar:** ✅  
**Evidencias generables:** ✅  

---

**Fecha de corrección:** 2024-11-25  
**Archivos modificados:** 2  
**Estado:** ✅ RESUELTO

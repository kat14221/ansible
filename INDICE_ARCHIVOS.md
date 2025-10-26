# Índice Completo de Archivos - Proyecto IPv6 VMWARE-101001

## Estructura Completa del Proyecto

```
ansible-debian/
│
├── 📄 ansible.cfg                    # Configuración principal de Ansible
├── 📄 .gitignore                     # Archivos a ignorar en Git
├── 📄 requirements.txt               # Dependencias Python/Ansible
├── 📄 README.md                      # Documentación principal
├── 📄 RESUMEN_PROYECTO.md           # Resumen ejecutivo
├── 📄 GUIA_USO.md                    # Guía de uso rápida
├── 📄 INDICE_ARCHIVOS.md            # Este archivo
│
├── 📁 docs/
│   └── CONTEXTO.md                  # Contexto académico y técnico
│
├── 📁 inventory/
│   └── hosts.yml                    # Inventario de hosts
│
├── 📁 playbooks/
│   ├── site.yml                     # Playbook maestro (ejecuta todo)
│   ├── deploy_all.yml               # Despliegue por pasos
│   └── test_only.yml                # Solo tests de conectividad
│
├── 📁 roles/
│   │
│   ├── 📁 vmware-router/            # Role: Crear VM router
│   │   ├── tasks/
│   │   │   └── main.yml            # Tareas de creación de VM
│   │   ├── handlers/
│   │   │   └── main.yml            # Handlers del role
│   │   ├── templates/               # Templates Jinja2
│   │   ├── files/                   # Archivos estáticos
│   │   └── vars/                    # Variables del role
│   │
│   ├── 📁 vmware-ubuntu/            # Role: Crear VM Ubuntu
│   │   ├── tasks/
│   │   │   └── main.yml
│   │   └── vars/
│   │
│   ├── 📁 vmware-windows/           # Role: Crear VM Windows
│   │   ├── tasks/
│   │   │   └── main.yml
│   │   └── vars/
│   │
│   ├── 📁 ios-basic-config/         # Role: Config IOS
│   │   ├── tasks/
│   │   │   └── main.yml            # Config routers/switches
│   │   └── templates/               # Templates de config
│   │
│   ├── 📁 debian-ipv6-router/       # Role: Config router IPv6
│   │   ├── tasks/
│   │   │   └── main.yml            # Config RADVD/DNSmasq
│   │   ├── handlers/
│   │   │   └── main.yml            # Handlers servicios
│   │   └── templates/
│   │       ├── radvd.conf.j2       # Template RADVD
│   │       └── dnsmasq.conf.j2     # Template DNSmasq
│   │
│   ├── 📁 debian-services/          # Role: Servicios aplicación
│   │   └── tasks/
│   │       └── main.yml            # Config Apache HTTP
│   │
│   ├── 📁 connectivity-tests/       # Role: Tests conectividad
│   │   └── tasks/
│   │       └── main.yml            # Tests de ping IPv6
│   │
│   └── 📁 traffic-capture/          # Role: Captura tráfico
│       └── tasks/
│           └── main.yml            # Captura con tcpdump
│
├── 📁 templates/
│   └── common/                      # Templates comunes
│
└── 📁 evidence/                     # Evidencias generadas
    ├── configs/                     # Configuraciones guardadas
    ├── pings/                       # Resultados de ping
    ├── pcaps/                       # Capturas de tráfico
    ├── services/                    # Estados de servicios
    └── logs/                        # Logs de Ansible
```

## Archivos por Categoría

### 📋 Documentación (7 archivos)
- `README.md` - Documentación principal
- `RESUMEN_PROYECTO.md` - Resumen ejecutivo
- `GUIA_USO.md` - Guía de uso rápida
- `INDICE_ARCHIVOS.md` - Este archivo
- `docs/CONTEXTO.md` - Contexto académico
- `requirements.txt` - Dependencias
- `.gitignore` - Control de versiones

### ⚙️ Configuración (2 archivos)
- `ansible.cfg` - Configuración Ansible
- `inventory/hosts.yml` - Inventario de hosts

### 🎬 Playbooks (3 archivos)
- `playbooks/site.yml` - Playbook maestro
- `playbooks/deploy_all.yml` - Despliegue por pasos
- `playbooks/test_only.yml` - Solo tests

### 🎭 Roles (8 roles, 20+ archivos)

#### iOS Configuration (1 archivo principal)
- `roles/ios-basic-config/tasks/main.yml`

#### Router IPv6 (4 archivos)
- `roles/debian-ipv6-router/tasks/main.yml`
- `roles/debian-ipv6-router/handlers/main.yml`
- `roles/debian-ipv6-router/templates/radvd.conf.j2`
- `roles/debian-ipv6-router/templates/dnsmasq.conf.j2`

#### Services (1 archivo)
- `roles/debian-services/tasks/main.yml`

#### VMware (3 roles, ~6 archivos)
- `roles/vmware-router/tasks/main.yml`
- `roles/vmware-ubuntu/tasks/main.yml`
- `roles/vmware-windows/tasks/main.yml`

#### Testing (2 archivos)
- `roles/connectivity-tests/tasks/main.yml`
- `roles/traffic-capture/tasks/main.yml`

### 📊 Evidencias (0 archivos inicialmente)

Los directorios de `evidence/` se poblarán al ejecutar los playbooks:

```
evidence/
├── configs/     # Running-configs, radvd.conf, etc.
├── pings/       # Resultados de tests de conectividad
├── pcaps/       # Capturas de tráfico IPv6
├── services/    # Estados de Apache, RADVD, DNSmasq
└── logs/        # ansible.log
```

## Resumen de Archivos

| Categoría | Cantidad | Ubicación |
|-----------|----------|-----------|
| Documentación | 7 | Raíz + docs/ |
| Configuración | 2 | Raíz + inventory/ |
| Playbooks | 3 | playbooks/ |
| Roles (tasks) | 8 | roles/*/tasks/ |
| Templates | 2 | roles/debian-ipv6-router/templates/ |
| Handlers | 2 | roles/*/handlers/ |
| Total Archivos | ~25 | |
| Directorios | 15+ | |

## Flujo de Ejecución

1. **Configuración**: Lee `ansible.cfg` e `inventory/hosts.yml`
2. **Ejecución**: `site.yml` llama a los roles en orden
3. **Roles**: Cada rol ejecuta sus tareas en `tasks/main.yml`
4. **Evidencias**: Se guardan en `evidence/` según se generan
5. **Logs**: Todo se registra en `evidence/logs/ansible.log`

## Mantenimiento

- **Agregar hosts**: Editar `inventory/hosts.yml`
- **Modificar configs**: Editar templates en `roles/*/templates/`
- **Nuevas tareas**: Agregar en `roles/*/tasks/main.yml`
- **Debug**: Ver logs en `evidence/logs/ansible.log`

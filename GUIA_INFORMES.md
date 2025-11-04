# 📊 Guía de Informes Técnicos y Carpetas Compartidas

## 🎯 Descripción

Este sistema genera automáticamente informes técnicos detallados de todos los hosts del proyecto y configura carpetas compartidas Samba para facilitar el acceso a evidencias y reportes.

---

## 📋 Componentes

### **1. Rol `technical-report`**
Genera informes técnicos en HTML y TXT con:
- Información del sistema (OS, kernel, hardware)
- Configuración de red IPv6
- Servicios activos
- Estado del firewall
- Configuración SSH hardening
- Running-config (dispositivos Cisco IOS)

### **2. Rol `shared-folders`**
Configura carpetas compartidas Samba en servidores Linux:
- `/srv/shared/reports` - Informes técnicos
- `/srv/shared/evidencias` - Evidencias de red
- `/srv/shared/publico` - Archivos compartidos generales

### **3. Playbook `generate_reports.yml`**
Orquesta la generación de informes y crea un índice HTML centralizado.

---

## 🚀 Uso

### **Generar Todos los Informes**
```bash
ansible-playbook playbooks/generate_reports.yml
```

### **Solo Generar Informes (sin carpetas compartidas)**
```bash
ansible-playbook playbooks/generate_reports.yml --tags reports
```

### **Solo Configurar Carpetas Compartidas**
```bash
ansible-playbook playbooks/generate_reports.yml --tags shares
```

### **Incluido en Ejecución Principal**
```bash
# Los informes se generan automáticamente al ejecutar site.yml
ansible-playbook playbooks/site.yml
```

---

## 📁 Estructura de Salida

### **Directorio de Informes**
```
evidence/technical_reports/
├── index.html                              # Índice principal (ABRIR ESTE)
├── debian-router_technical_report.html     # Informe HTML debian-router
├── debian-router_technical_report.txt      # Informe TXT debian-router
├── ubuntu-pc_technical_report.html
├── ubuntu-pc_technical_report.txt
├── windows-pc_technical_report.html
├── windows-pc_technical_report.txt
├── physical-router_technical_report.html
├── physical-router_technical_report.txt
└── ...
```

### **Archivo Comprimido**
```
evidence/informes_tecnicos_2025-11-04.zip   # Todos los informes en ZIP
```

---

## 🌐 Acceso a Carpetas Compartidas

### **Desde Windows**

#### **Explorador de Archivos:**
1. Presionar `Win + R`
2. Escribir: `\\172.17.25.126\reports`
3. Presionar Enter

#### **Rutas Disponibles:**
```
\\172.17.25.126\reports      # debian-router - Informes técnicos
\\172.17.25.126\evidencias   # debian-router - Evidencias de red
\\172.17.25.126\publico      # debian-router - Archivos generales

\\2025:db8:101::10\reports   # ubuntu-pc - Informes técnicos
\\2025:db8:101::10\evidencias
\\2025:db8:101::10\publico
```

### **Desde Linux/Mac**

#### **Nautilus/Files (GUI):**
1. Presionar `Ctrl + L`
2. Escribir: `smb://172.17.25.126/reports`
3. Presionar Enter

#### **Línea de comandos:**
```bash
# Montar carpeta compartida
sudo mkdir -p /mnt/reports
sudo mount -t cifs //172.17.25.126/reports /mnt/reports -o guest

# Ver contenido
ls -la /mnt/reports

# Desmontar
sudo umount /mnt/reports
```

---

## 📊 Contenido de los Informes

### **Informe HTML (Formato Visual)**
- Header con información del host
- Información general del sistema
- Recursos de hardware (CPU, RAM, disco)
- Configuración de red IPv6 completa
- Servicios activos (systemd)
- Estado del firewall (firewalld)
- Configuración SSH hardening
- Running-config de Cisco IOS (si aplica)
- Diseño responsive y profesional

### **Informe TXT (Formato Texto Plano)**
- Misma información que HTML
- Formato estructurado con secciones
- Fácil de procesar con scripts
- Compatible con cualquier editor de texto

### **Índice HTML (index.html)**
- Vista general de todos los hosts
- Estadísticas por tipo de dispositivo
- Enlaces directos a cada informe
- Diseño visual atractivo
- Filtrado por badges (Linux, Network, Windows)

---

## 🔧 Ubicaciones en el Sistema

### **En la VM de Control (localhost):**
```
/tmp/ansible_reports/           # Informes temporales
evidence/technical_reports/     # Informes finales
evidence/informes_tecnicos_*.zip # Archivo comprimido
```

### **En debian-router:**
```
/srv/shared/reports/            # Informes copiados aquí (vía Samba)
/srv/shared/evidencias/         # Evidencias copiadas aquí
/srv/shared/publico/            # Archivos compartidos
```

### **En ubuntu-pc:**
```
/srv/shared/reports/            # Informes copiados aquí (vía Samba)
/srv/shared/evidencias/         # Evidencias copiadas aquí
/srv/shared/publico/            # Archivos compartidos
```

---

## 🔐 Seguridad de Carpetas Compartidas

### **Configuración Actual (Guest Access)**
- **Usuario:** guest (sin contraseña)
- **Permisos:** Lectura y escritura
- **Propósito:** Laboratorio académico

### **Para Producción (Recomendado):**
Modificar `roles/shared-folders/tasks/main.yml`:

```yaml
# Deshabilitar guest access
guest ok = no

# Crear usuario Samba
- name: Crear usuario Samba
  shell: |
    (echo "password"; echo "password") | smbpasswd -a ansible -s
  become: yes

# Configurar permisos específicos
create mask = 0770
directory mask = 0770
valid users = ansible
```

---

## 📦 Dependencias

### **Instaladas Automáticamente:**
- `samba` - Servidor de archivos compartidos
- `samba-common-bin` - Herramientas Samba
- `cifs-utils` - Cliente CIFS/SMB
- `firewalld` - Firewall (puerto Samba abierto automáticamente)

### **Verificar Instalación:**
```bash
# En debian-router o ubuntu-pc
systemctl status smbd
systemctl status nmbd
sudo firewall-cmd --list-services | grep samba
```

---

## 🆘 Solución de Problemas

### **No puedo acceder a carpetas compartidas desde Windows**

```bash
# Verificar que Samba está corriendo
ssh ansible@172.17.25.126
systemctl status smbd nmbd

# Verificar firewall
sudo firewall-cmd --list-all | grep samba

# Ver logs de Samba
sudo tail -f /var/log/samba/log.smbd
```

### **Carpeta vacía o no se copian archivos**

```bash
# Verificar permisos
ls -la /srv/shared/reports/

# Copiar manualmente desde VM de control
scp evidence/technical_reports/* ansible@172.17.25.126:/srv/shared/reports/
```

### **No se generan informes HTML**

```bash
# Verificar que existe el template
ls -la roles/technical-report/templates/

# Ejecutar con verbose
ansible-playbook playbooks/generate_reports.yml -vv
```

---

## 🎨 Personalización

### **Cambiar Estilo de Informes HTML**

Editar: `roles/technical-report/templates/technical_report.html.j2`

```html
<!-- Cambiar colores principales -->
<style>
    .header {
        background: linear-gradient(135deg, #TU_COLOR1, #TU_COLOR2);
    }
</style>
```

### **Añadir Más Información a Informes**

Editar: `roles/technical-report/tasks/main.yml`

```yaml
- name: Obtener información adicional
  command: tu_comando_aqui
  register: nueva_info
  
# Luego añadir {{ nueva_info.stdout }} al template
```

### **Configurar Más Carpetas Compartidas**

Editar: `roles/shared-folders/tasks/main.yml`

```yaml
- name: Crear nueva carpeta compartida
  file:
    path: /srv/shared/nueva_carpeta
    state: directory
    mode: '0777'
```

---

## ✅ Checklist de Validación

- [ ] Ejecutar `ansible-playbook playbooks/generate_reports.yml`
- [ ] Verificar `evidence/technical_reports/index.html` existe
- [ ] Abrir index.html en navegador
- [ ] Verificar que hay informes HTML y TXT para cada host
- [ ] Desde Windows, acceder a `\\172.17.25.126\reports`
- [ ] Verificar que archivos son visibles en carpeta compartida
- [ ] Descargar archivo ZIP: `evidence/informes_tecnicos_*.zip`
- [ ] Verificar Samba activo: `systemctl status smbd`

---

## 📸 Capturas de Ejemplo

### **Índice HTML:**
- Dashboard visual con estadísticas
- Cards por cada host
- Enlaces a informes HTML y TXT

### **Informe Individual:**
- Header con gradiente
- Secciones organizadas por tipo de información
- Formato de código con syntax highlighting
- Responsive design

### **Carpeta Compartida en Windows:**
- Archivos visibles directamente en Explorador
- Descarga rápida con doble clic
- Compatible con todas las versiones de Windows

---

**Última actualización:** 2025-11-04  
**Proyecto:** VMWARE-101001

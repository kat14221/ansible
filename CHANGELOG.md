# 📝 Registro de Cambios

## [2025-11-04] - Mejoras de Idempotencia y Pruebas

### ✨ Nuevas Características
- **Script Bootstrap Idempotente**: Ahora `bootstrap_control_vm.sh` verifica qué ya está instalado antes de instalar
- **Sistema de Informes Técnicos**: Nuevo rol `technical-report` genera informes HTML/TXT profesionales
- **Carpetas Compartidas Samba**: Nuevo rol `shared-folders` configura acceso remoto a evidencias
- **Topología Documentada**: Archivo `TOPOLOGIA_RED.md` con diagrama completo de la red

### 🔧 Mejoras
- **Bootstrap inteligente**:
  - Verifica cada paquete apt antes de instalar
  - Detecta si pyvmomi ya está instalado
  - Verifica collections de Ansible instaladas
  - Solo descarga lo que falta
  - Muestra resumen detallado al final
- **Inventario corregido**:
  - `physical-router` con IPs correctas (G0/0/0: 100::2, G0/0/1: 101::2)
  - Eliminado `ios-core-router` duplicado
  - Añadido `switch-3` real
  - `debian-router` confirmado como 101::1
- **Playbook principal actualizado**:
  - Informes técnicos integrados
  - Carpetas compartidas configuradas automáticamente
  - Hardening solo en `linux_servers` (no en network devices)

### 🐛 Correcciones
- **PEP 668**: Solucionado error "externally-managed-environment" en Debian 12
  - Paquetes Python instalados vía apt cuando sea posible
  - Solo usa pip para pyvmomi (no disponible en apt)
  - Usa `--break-system-packages` de forma segura
- **Topología**: Corregidas IPs según configuración real del usuario
  - debian-router: 2025:db8:101::1 (confirmado)
  - physical-router G0/0/1: 2025:db8:101::2 (confirmado)
  - ubuntu-pc: 2025:db8:101::10
  - windows-pc: 2025:db8:101::11

### 📚 Documentación
- `QUICK_START_DESDE_CERO.md`: Guía completa para instalación desde cero
- `TOPOLOGIA_RED.md`: Diagrama visual de la red con todas las IPs
- `GUIA_INFORMES.md`: Cómo usar el sistema de informes técnicos
- `IMPLEMENTACION_COMPLETA.md`: Estado de los 12 puntos del proyecto

### 🎯 Roles Nuevos
- `technical-report`: Genera informes HTML/TXT de cada host
- `shared-folders`: Configura Samba para acceso remoto a archivos

### 📦 Archivos Importantes
| Archivo | Descripción |
|---------|-------------|
| `bootstrap_control_vm.sh` | Script de instalación idempotente |
| `playbooks/generate_reports.yml` | Genera todos los informes |
| `inventory/hosts.yml` | Inventario con topología corregida |
| `.vault_pass` | Password del Vault (no commitear) |

---

## [Versión Anterior] - Implementación Inicial

### ✅ Implementado
1. ✅ Bootstrap de VM de Control
2. ✅ VMs Idempotentes (comprobación de existencia)
3. ✅ Ansible Vault para credenciales
4. ✅ Dependencias centralizadas
5. ✅ Evidencias automáticas
6. ✅ Conectividad IPv6 total
7. ✅ Firewall con firewalld (reglas asimétricas)
8. ✅ Firewall policy aplicada
9. ⚠️ Laboratorio y apps (pendiente manual)
10. ✅ Hardening de seguridad
11. ✅ SSH seguro con llaves
12. ✅ Evidencias mínimas

---

## 🚀 Próximas Mejoras Planificadas

- [ ] Añadir verificación de conectividad antes de ejecutar playbooks
- [ ] Mejorar manejo de errores en bootstrap
- [ ] Añadir modo verbose opcional (-v, -vv, -vvv)
- [ ] Crear rol para laboratorio de gaming (Punto 9)
- [ ] Añadir tests automatizados con molecule
- [ ] Dashboard web para visualizar estado del proyecto

---

**Mantenido por:** Ansible Project Team  
**Última actualización:** 2025-11-04

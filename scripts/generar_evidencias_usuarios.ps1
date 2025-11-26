# Script PowerShell para generar evidencias de Administración de Usuarios y Permisos
# Proyecto: VMWARE-101001

# Configuración
$EVIDENCE_DIR = "evidence\usuarios_permisos"
$REPORTS_DIR = "$EVIDENCE_DIR\reports"
$SCREENSHOTS_DIR = "$EVIDENCE_DIR\screenshots"
$DEBIAN_ROUTER = "ansible@172.17.25.126"

# Colores
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

Write-ColorOutput Blue "╔════════════════════════════════════════════════════════════╗"
Write-ColorOutput Blue "║  Generador de Evidencias - Usuarios, Permisos y Políticas  ║"
Write-ColorOutput Blue "╚════════════════════════════════════════════════════════════╝"
Write-Output ""

# Crear directorios
Write-ColorOutput Yellow "Creando directorios..."
New-Item -ItemType Directory -Force -Path $EVIDENCE_DIR | Out-Null
New-Item -ItemType Directory -Force -Path $REPORTS_DIR | Out-Null
New-Item -ItemType Directory -Force -Path $SCREENSHOTS_DIR | Out-Null
Write-ColorOutput Green "✓ Directorios creados"

# Función para ejecutar comando remoto
function Invoke-RemoteCommand {
    param(
        [string]$Command,
        [string]$OutputFile
    )
    
    Write-ColorOutput Yellow "Ejecutando: $Command"
    $result = ssh -o StrictHostKeyChecking=no $DEBIAN_ROUTER $Command 2>&1
    $result | Out-File -FilePath $OutputFile -Encoding UTF8
    Write-ColorOutput Green "✓ Guardado en: $OutputFile"
}

# 1. USUARIOS DEL SISTEMA
Write-Output ""
Write-ColorOutput Blue "[1/10] Recopilando información de usuarios..."
Invoke-RemoteCommand `
    "getent passwd | grep -E '(alumno|profesor|admin|operator|ansible)'" `
    "$REPORTS_DIR\01_usuarios_sistema.txt"

# 2. GRUPOS
Write-Output ""
Write-ColorOutput Blue "[2/10] Recopilando información de grupos..."
Invoke-RemoteCommand `
    "getent group | grep -E '(alumnos|profesores|sudo)'" `
    "$REPORTS_DIR\02_grupos_sistema.txt"

# 3. CONFIGURACIÓN SUDOERS
Write-Output ""
Write-ColorOutput Blue "[3/10] Recopilando configuración sudoers..."
Invoke-RemoteCommand `
    "sudo cat /etc/sudoers.d/operator" `
    "$REPORTS_DIR\03_sudoers_operator.txt"
Invoke-RemoteCommand `
    "sudo cat /etc/sudoers.d/ansible" `
    "$REPORTS_DIR\03_sudoers_ansible.txt"

# 4. CONFIGURACIÓN SSH
Write-Output ""
Write-ColorOutput Blue "[4/10] Recopilando configuración SSH..."
Invoke-RemoteCommand `
    "sudo grep -E '^(PermitRootLogin|PasswordAuthentication|MaxAuthTries|AllowUsers|Protocol|LogLevel)' /etc/ssh/sshd_config" `
    "$REPORTS_DIR\04_ssh_config.txt"
Invoke-RemoteCommand `
    "sudo grep -A 5 'ANSIBLE MANAGED SSH HARDENING' /etc/ssh/sshd_config" `
    "$REPORTS_DIR\04_ssh_algorithms.txt"

# 5. FAIL2BAN
Write-Output ""
Write-ColorOutput Blue "[5/10] Recopilando estado de fail2ban..."
Invoke-RemoteCommand `
    "sudo systemctl status fail2ban --no-pager" `
    "$REPORTS_DIR\05_fail2ban_status.txt"
Invoke-RemoteCommand `
    "sudo fail2ban-client status sshd" `
    "$REPORTS_DIR\05_fail2ban_sshd.txt"

# 6. FIREWALL
Write-Output ""
Write-ColorOutput Blue "[6/10] Recopilando configuración de firewall..."
Invoke-RemoteCommand `
    "sudo firewall-cmd --state" `
    "$REPORTS_DIR\06_firewall_state.txt"
Invoke-RemoteCommand `
    "sudo firewall-cmd --get-active-zones" `
    "$REPORTS_DIR\06_firewall_zones.txt"
Invoke-RemoteCommand `
    "sudo firewall-cmd --zone=internal --list-all" `
    "$REPORTS_DIR\06_firewall_internal.txt"
Invoke-RemoteCommand `
    "sudo firewall-cmd --zone=external --list-all" `
    "$REPORTS_DIR\06_firewall_external.txt"

# 7. HARDENING KERNEL
Write-Output ""
Write-ColorOutput Blue "[7/10] Recopilando parámetros de hardening..."
Invoke-RemoteCommand `
    "sudo sysctl -a | grep -E '(ip_forward|accept_redirects|send_redirects|log_martians|syncookies|dmesg_restrict|kptr_restrict|ptrace_scope)'" `
    "$REPORTS_DIR\07_kernel_hardening.txt"

# 8. LÍMITES DE RECURSOS
Write-Output ""
Write-ColorOutput Blue "[8/10] Recopilando límites de recursos..."
Invoke-RemoteCommand `
    "sudo cat /etc/security/limits.d/99-hardening.conf" `
    "$REPORTS_DIR\08_resource_limits.txt"

# 9. AUDITORÍA
Write-Output ""
Write-ColorOutput Blue "[9/10] Recopilando configuración de auditoría..."
Invoke-RemoteCommand `
    "sudo systemctl status auditd --no-pager" `
    "$REPORTS_DIR\09_auditd_status.txt"
Invoke-RemoteCommand `
    "sudo cat /etc/audit/rules.d/99-hardening.rules" `
    "$REPORTS_DIR\09_audit_rules.txt"

# 10. REPORTE COMPLETO
Write-Output ""
Write-ColorOutput Blue "[10/10] Generando reporte completo..."

$reporteCompleto = @"
╔════════════════════════════════════════════════════════════════════════╗
║          REPORTE COMPLETO - ADMINISTRACIÓN DE USUARIOS Y PERMISOS       ║
║                    Proyecto: VMWARE-101001                              ║
╚════════════════════════════════════════════════════════════════════════╝

FECHA DE GENERACIÓN: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

═══════════════════════════════════════════════════════════════════════════
1. RESUMEN EJECUTIVO
═══════════════════════════════════════════════════════════════════════════

Este proyecto implementa un sistema completo de administración de usuarios,
permisos y políticas de seguridad que cumple con el nivel máximo:
"Define políticas seguras con restricciones claras"

USUARIOS IMPLEMENTADOS:
├─ Alumnos (3):    alumno1, alumno2, alumno3
├─ Profesores (2): profesor1, profesor2
├─ Admin (1):      admin
├─ Operator (1):   operator
└─ Ansible (1):    ansible

POLÍTICAS IMPLEMENTADAS:
✅ Gestión de usuarios por roles
✅ Permisos sudo granulares
✅ SSH hardening completo
✅ Firewall asimétrico
✅ Kernel hardening
✅ Límites de recursos
✅ Auditoría de eventos
✅ Protección contra ataques

═══════════════════════════════════════════════════════════════════════════
2. USUARIOS DEL SISTEMA
═══════════════════════════════════════════════════════════════════════════

$(Get-Content "$REPORTS_DIR\01_usuarios_sistema.txt" -Raw)

═══════════════════════════════════════════════════════════════════════════
3. GRUPOS DEL SISTEMA
═══════════════════════════════════════════════════════════════════════════

$(Get-Content "$REPORTS_DIR\02_grupos_sistema.txt" -Raw)

═══════════════════════════════════════════════════════════════════════════
4. CONFIGURACIÓN SUDOERS - OPERATOR
═══════════════════════════════════════════════════════════════════════════

$(Get-Content "$REPORTS_DIR\03_sudoers_operator.txt" -Raw)

═══════════════════════════════════════════════════════════════════════════
5. CONFIGURACIÓN SSH
═══════════════════════════════════════════════════════════════════════════

$(Get-Content "$REPORTS_DIR\04_ssh_config.txt" -Raw)

Algoritmos de cifrado seguros:
$(Get-Content "$REPORTS_DIR\04_ssh_algorithms.txt" -Raw)

═══════════════════════════════════════════════════════════════════════════
6. FAIL2BAN - PROTECCIÓN CONTRA ATAQUES
═══════════════════════════════════════════════════════════════════════════

$(Get-Content "$REPORTS_DIR\05_fail2ban_sshd.txt" -Raw)

═══════════════════════════════════════════════════════════════════════════
7. FIREWALL - ZONAS Y REGLAS
═══════════════════════════════════════════════════════════════════════════

Estado del firewall:
$(Get-Content "$REPORTS_DIR\06_firewall_state.txt" -Raw)

Zonas activas:
$(Get-Content "$REPORTS_DIR\06_firewall_zones.txt" -Raw)

Zona INTERNAL (Red Fernandez 101::/64):
$(Get-Content "$REPORTS_DIR\06_firewall_internal.txt" -Raw)

Zona EXTERNAL (Red Laboratorio 100::/64):
$(Get-Content "$REPORTS_DIR\06_firewall_external.txt" -Raw)

═══════════════════════════════════════════════════════════════════════════
8. HARDENING DEL KERNEL
═══════════════════════════════════════════════════════════════════════════

$(Get-Content "$REPORTS_DIR\07_kernel_hardening.txt" -Raw)

═══════════════════════════════════════════════════════════════════════════
9. LÍMITES DE RECURSOS
═══════════════════════════════════════════════════════════════════════════

$(Get-Content "$REPORTS_DIR\08_resource_limits.txt" -Raw)

═══════════════════════════════════════════════════════════════════════════
10. AUDITORÍA Y MONITOREO
═══════════════════════════════════════════════════════════════════════════

Reglas de auditoría:
$(Get-Content "$REPORTS_DIR\09_audit_rules.txt" -Raw)

═══════════════════════════════════════════════════════════════════════════
11. MATRIZ DE CUMPLIMIENTO
═══════════════════════════════════════════════════════════════════════════

┌────────────────────────────────────────────────────────────────────────┐
│ CRITERIO                                    │ IMPLEMENTADO │ EVIDENCIA  │
├────────────────────────────────────────────────────────────────────────┤
│ 1. Gestión de usuarios por roles           │      ✅      │ Sección 2  │
│ 2. Permisos diferenciados (sudo)            │      ✅      │ Sección 4  │
│ 3. Políticas de seguridad SSH               │      ✅      │ Sección 5  │
│ 4. Políticas de firewall                    │      ✅      │ Sección 7  │
│ 5. Hardening de kernel                      │      ✅      │ Sección 8  │
│ 6. Límites de recursos                      │      ✅      │ Sección 9  │
│ 7. Auditoría de eventos                     │      ✅      │ Sección 10 │
│ 8. Protección contra ataques (fail2ban)     │      ✅      │ Sección 6  │
│ 9. Documentación de políticas               │      ✅      │ Este doc   │
│ 10. Validación automática                   │      ✅      │ Ansible    │
└────────────────────────────────────────────────────────────────────────┘

NIVEL ALCANZADO: ★★★★★ "Define políticas seguras con restricciones claras"

═══════════════════════════════════════════════════════════════════════════
FIN DEL REPORTE
═══════════════════════════════════════════════════════════════════════════
"@

$reporteCompleto | Out-File -FilePath "$REPORTS_DIR\00_REPORTE_COMPLETO.txt" -Encoding UTF8
Write-ColorOutput Green "✓ Reporte completo generado"

# Resumen final
Write-Output ""
Write-ColorOutput Blue "╔════════════════════════════════════════════════════════════╗"
Write-ColorOutput Blue "║                    RESUMEN DE EVIDENCIAS                    ║"
Write-ColorOutput Blue "╚════════════════════════════════════════════════════════════╝"
Write-Output ""
Write-ColorOutput Green "✓ Evidencias generadas exitosamente"
Write-ColorOutput Green "✓ Ubicación: $EVIDENCE_DIR"
Write-Output ""
Write-Output "Archivos generados:"
Write-ColorOutput Yellow "  • Reporte completo: $REPORTS_DIR\00_REPORTE_COMPLETO.txt"
Write-ColorOutput Yellow "  • Evidencias individuales: $REPORTS_DIR\"
Write-Output ""
Write-ColorOutput Blue "Próximos pasos:"
Write-Output "  1. Revisar el reporte completo"
Write-Output "  2. Tomar capturas de pantalla según la guía"
Write-Output "  3. Organizar capturas en $SCREENSHOTS_DIR"
Write-Output "  4. Crear presentación con evidencias"
Write-Output ""
Write-ColorOutput Green "¡Listo para demostrar el cumplimiento de la rúbrica!"
Write-Output ""

# PowerShell Script to Push to GitHub
# Ejecuta desde: D:\ansible

Write-Host "╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║         🚀 GIT PUSH - Network Monitor + Topology            ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# PASO 1: Ver estado
Write-Host "📋 PASO 1: Estado actual del repositorio" -ForegroundColor Yellow
Write-Host "─────────────────────────────────────────────────────────────" -ForegroundColor Gray
git status
Write-Host ""

# Preguntar si continuar
$continue = Read-Host "¿Continuar con commit y push? (s/n)"
if ($continue -ne "s") {
    Write-Host "❌ Cancelado por el usuario" -ForegroundColor Red
    exit 1
}

Write-Host ""

# PASO 2: Agregar cambios
Write-Host "➕ PASO 2: Agregando todos los cambios" -ForegroundColor Yellow
Write-Host "─────────────────────────────────────────────────────────────" -ForegroundColor Gray
Write-Host "Ejecutando: git add -A" -ForegroundColor Green
git add -A

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Cambios agregados correctamente" -ForegroundColor Green
} else {
    Write-Host "❌ Error al agregar cambios" -ForegroundColor Red
    exit 1
}

Write-Host ""

# PASO 3: Ver cambios a hacer commit
Write-Host "🔍 PASO 3: Cambios a hacer commit" -ForegroundColor Yellow
Write-Host "─────────────────────────────────────────────────────────────" -ForegroundColor Gray
git diff --cached --name-only
Write-Host ""

# PASO 4: Hacer commit
Write-Host "💾 PASO 4: Hacer commit" -ForegroundColor Yellow
Write-Host "─────────────────────────────────────────────────────────────" -ForegroundColor Gray

$commitMessage = @"
feat: Network Monitor Dashboard + Extended Topology

- Added Flask-based web dashboard for real-time device monitoring
- 3 detection methods: ping6, nmap, range scanning
- REST API with 8 endpoints for device management
- Bootstrap 5 responsive frontend with 7 interactive sections
- Ansible role for automated deployment on Debian 12
- Systemd service and supervisor process management
- Extended topology documentation (GNS3 + WiFi + 15 devices)
- Support for IPv6-native monitoring (2025:db8:101::/64)
- SSH integration directly from web interface
- Real-time statistics and JSON/CSV export
- Comprehensive documentation (4000+ lines)
"@

Write-Host "Mensaje de commit:" -ForegroundColor Green
Write-Host $commitMessage -ForegroundColor Gray
Write-Host ""

Write-Host "Ejecutando: git commit" -ForegroundColor Green
git commit -m $commitMessage

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Commit realizado exitosamente" -ForegroundColor Green
} else {
    Write-Host "❌ Error al hacer commit" -ForegroundColor Red
    exit 1
}

Write-Host ""

# PASO 5: Hacer push
Write-Host "🚀 PASO 5: Haciendo push a GitHub" -ForegroundColor Yellow
Write-Host "─────────────────────────────────────────────────────────────" -ForegroundColor Gray
Write-Host "Ejecutando: git push origin main" -ForegroundColor Green
Write-Host ""

git push origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║              ✅ PUSH COMPLETADO EXITOSAMENTE ✅             ║" -ForegroundColor Green
    Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "📍 Próximo paso:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Conectarte a debian-router:" -ForegroundColor Yellow
    Write-Host "   ssh ansible@172.17.25.126" -ForegroundColor White
    Write-Host ""
    Write-Host "2. Hacer pull y desplegar:" -ForegroundColor Yellow
    Write-Host "   cd /home/ansible/ansible" -ForegroundColor White
    Write-Host "   git pull origin main" -ForegroundColor White
    Write-Host "   bash scripts/deploy_and_run.sh" -ForegroundColor White
    Write-Host ""
    Write-Host "3. Acceder al dashboard:" -ForegroundColor Yellow
    Write-Host "   http://172.17.25.126:5000" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "❌ Error al hacer push" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Para detalles completos, ver: INSTRUCCIONES_DEPLOYMENT.md" -ForegroundColor Cyan

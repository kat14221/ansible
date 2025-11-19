# Script: Reparar Conectividad de Red
# Descripción: Ejecuta playbook para corregir DHCPv6, NAT e internet

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "🔧 REPARACIÓN DE CONECTIVIDAD DE RED" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Cambiar al directorio del proyecto
Set-Location -Path "d:\ansible"

Write-Host "📋 Verificando conectividad con debian-router..." -ForegroundColor Yellow
ansible -i inventory/hosts.yml debian_router -m ping

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ No se puede conectar a debian-router" -ForegroundColor Red
    Write-Host "   Verifica que la IP 172.17.25.122 sea correcta" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "✅ Conexión exitosa. Aplicando correcciones..." -ForegroundColor Green
Write-Host ""

# Ejecutar playbook de reparación
ansible-playbook playbooks/fix_network_connectivity.yml -i inventory/hosts.yml -v

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "✅ CORRECCIONES APLICADAS EXITOSAMENTE" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 VERIFICACIÓN MANUAL EN WINDOWS:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Ejecuta en PowerShell:" -ForegroundColor White
    Write-Host "   ipconfig /all" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "2. Busca 'Dirección IPv6' que empiece con:" -ForegroundColor White
    Write-Host "   2025:db8:101::11  (✅ IP corta - CORRECTO)" -ForegroundColor Green
    Write-Host "   2025:db8:101:0:xxxx:...  (❌ IP larga - INCORRECTO)" -ForegroundColor Red
    Write-Host ""
    Write-Host "3. Prueba internet IPv6:" -ForegroundColor White
    Write-Host "   ping -6 google.com" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "4. Prueba SSH (si ya configuraste usuario ansible):" -ForegroundColor White
    Write-Host "   ssh ansible@2025:db8:101::11" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "❌ Error al aplicar correcciones" -ForegroundColor Red
    Write-Host "   Revisa los logs arriba para más detalles" -ForegroundColor Red
}

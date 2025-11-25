# Script de reparación rápida WinRM
# Ejecutar en Windows como Administrador

Write-Host "=== REPARACIÓN RÁPIDA WINRM ===" -ForegroundColor Cyan

# 1. Habilitar WinRM forzadamente
Write-Host "Habilitando WinRM..." -ForegroundColor Yellow
Enable-PSRemoting -Force -SkipNetworkProfileCheck

# 2. Configurar autenticación básica
Write-Host "Configurando autenticación..." -ForegroundColor Yellow
Set-Item WSMan:\localhost\Service\Auth\Basic $true -Force
Set-Item WSMan:\localhost\Service\AllowUnencrypted $true -Force

# 3. Crear listener HTTP
Write-Host "Creando listener HTTP..." -ForegroundColor Yellow
winrm delete winrm/config/Listener?Address=*+Transport=HTTP 2>$null
winrm create winrm/config/Listener?Address=*+Transport=HTTP

# 4. Crear/verificar usuario ansible
Write-Host "Configurando usuario ansible..." -ForegroundColor Yellow
$password = ConvertTo-SecureString "Ansible123!" -AsPlainText -Force
try {
    New-LocalUser -Name "ansible" -Password $password -FullName "Ansible User" -Description "Usuario para Ansible" -ErrorAction Stop
    Write-Host "Usuario ansible creado" -ForegroundColor Green
} catch {
    Write-Host "Usuario ansible ya existe" -ForegroundColor Gray
}
Add-LocalGroupMember -Group "Administrators" -Member "ansible" -ErrorAction SilentlyContinue

# 5. Configurar firewall
Write-Host "Configurando firewall..." -ForegroundColor Yellow
Remove-NetFirewallRule -DisplayName "WinRM HTTP" -ErrorAction SilentlyContinue
New-NetFirewallRule -DisplayName "WinRM HTTP" -Direction Inbound -LocalPort 5985 -Protocol TCP -Action Allow

# 6. Iniciar servicio WinRM
Write-Host "Iniciando servicio WinRM..." -ForegroundColor Yellow
Start-Service WinRM
Set-Service WinRM -StartupType Automatic

# 7. Test final
Write-Host "Probando configuración..." -ForegroundColor Yellow
Test-WSMan -ComputerName localhost

# 8. Mostrar configuración
Write-Host "Configuración actual:" -ForegroundColor Yellow
winrm get winrm/config/service

Write-Host "`n✅ CONFIGURACIÓN COMPLETADA" -ForegroundColor Green
Write-Host "Ahora prueba desde Ansible:" -ForegroundColor Cyan
Write-Host "ansible-playbook playbooks/simple_windows_test.yml -i inventory/hosts.yml" -ForegroundColor Yellow
# Script para CONFIGURAR IPv6 Y WinRM en Windows
# Ejecutar como Administrador

Write-Host "=== CONFIGURACIÓN COMPLETA IPv6 + WINRM ===" -ForegroundColor Cyan

# 1. Verificar interfaces de red
Write-Host "`n[1] Interfaces de red disponibles:" -ForegroundColor Yellow
Get-NetAdapter | Where-Object {$_.Status -eq "Up"} | Format-Table Name, InterfaceDescription, LinkSpeed

# 2. Configurar IPv6 estática
Write-Host "`n[2] Configurando IPv6 estática..." -ForegroundColor Yellow
$adapter = Get-NetAdapter | Where-Object {$_.Status -eq "Up"} | Select-Object -First 1
if ($adapter) {
    Write-Host "Usando adaptador: $($adapter.Name)" -ForegroundColor Green
    
    # Remover IPv6 existentes que comiencen con 2025:
    $existingIPv6 = Get-NetIPAddress -InterfaceIndex $adapter.InterfaceIndex -AddressFamily IPv6 | Where-Object {$_.IPAddress -like "2025:*"}
    if ($existingIPv6) {
        Write-Host "Removiendo IPv6 existente..." -ForegroundColor Yellow
        Remove-NetIPAddress -InterfaceIndex $adapter.InterfaceIndex -IPAddress $existingIPv6.IPAddress -Confirm:$false -ErrorAction SilentlyContinue
    }
    
    # Configurar la nueva IP
    try {
        New-NetIPAddress -InterfaceIndex $adapter.InterfaceIndex -IPAddress "2025:db8:101::11" -PrefixLength 64 -ErrorAction Stop
        Write-Host "✅ IPv6 configurado: 2025:db8:101::11/64" -ForegroundColor Green
    } catch {
        Write-Host "❌ Error configurando IPv6: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "❌ No se encontraron adaptadores activos" -ForegroundColor Red
}

# 3. Configurar WinRM FORZADAMENTE
Write-Host "`n[3] Configurando WinRM..." -ForegroundColor Yellow

# Detener servicio
Stop-Service WinRM -Force -ErrorAction SilentlyContinue
Start-Sleep 3

# Limpiar configuración existente
Write-Host "Limpiando configuración WinRM..." -ForegroundColor Yellow
winrm delete winrm/config/Listener?Address=*+Transport=HTTP 2>$null
winrm delete winrm/config/Listener?Address=*+Transport=HTTPS 2>$null

# Configuración desde cero
Write-Host "Configurando WinRM desde cero..." -ForegroundColor Yellow
winrm quickconfig -q -force
Enable-PSRemoting -Force -SkipNetworkProfileCheck

# Configurar autenticación
Set-Item WSMan:\localhost\Service\Auth\Basic $true -Force
Set-Item WSMan:\localhost\Service\AllowUnencrypted $true -Force
Set-Item WSMan:\localhost\Service\Auth\Certificate $false -Force
Set-Item WSMan:\localhost\Service\Auth\CredSSP $false -Force
Set-Item WSMan:\localhost\Service\Auth\Kerberos $true -Force
Set-Item WSMan:\localhost\Service\Auth\Negotiate $true -Force

# Crear listener HTTP específico
Write-Host "Creando listener HTTP..." -ForegroundColor Yellow
winrm create winrm/config/Listener?Address=*+Transport=HTTP @{Port="5985"}

# 4. Configurar firewall ESPECÍFICAMENTE
Write-Host "`n[4] Configurando firewall..." -ForegroundColor Yellow

# Remover reglas conflictivas
Remove-NetFirewallRule -DisplayName "*WinRM*" -ErrorAction SilentlyContinue

# Crear reglas específicas
New-NetFirewallRule -DisplayName "WinRM-HTTP-In-IPv4" -Direction Inbound -Protocol TCP -LocalPort 5985 -Action Allow -Profile Any -Enabled True
New-NetFirewallRule -DisplayName "WinRM-HTTP-In-IPv6" -Direction Inbound -Protocol TCP -LocalPort 5985 -Action Allow -Profile Any -Enabled True

# 5. Configurar usuario ansible
Write-Host "`n[5] Configurando usuario ansible..." -ForegroundColor Yellow
$password = ConvertTo-SecureString "Ansible123!" -AsPlainText -Force

# Remover si existe
Remove-LocalUser -Name "ansible" -ErrorAction SilentlyContinue

# Crear nuevo
try {
    New-LocalUser -Name "ansible" -Password $password -FullName "Ansible User" -Description "Usuario para Ansible" -PasswordNeverExpires -ErrorAction Stop
    Add-LocalGroupMember -Group "Administrators" -Member "ansible" -ErrorAction Stop
    Write-Host "✅ Usuario ansible configurado" -ForegroundColor Green
} catch {
    Write-Host "❌ Error configurando usuario: $($_.Exception.Message)" -ForegroundColor Red
}

# 6. Iniciar servicios
Write-Host "`n[6] Iniciando servicios..." -ForegroundColor Yellow
Start-Service WinRM
Set-Service WinRM -StartupType Automatic

# 7. VERIFICACIÓN FINAL
Write-Host "`n[7] VERIFICACIÓN FINAL:" -ForegroundColor Cyan

# IPv6
$ipv6Final = Get-NetIPAddress -AddressFamily IPv6 | Where-Object {$_.IPAddress -like "2025:*"}
if ($ipv6Final) {
    Write-Host "✅ IPv6: $($ipv6Final.IPAddress)" -ForegroundColor Green
} else {
    Write-Host "❌ IPv6 no configurado" -ForegroundColor Red
}

# WinRM
try {
    Test-WSMan -ComputerName localhost
    Write-Host "✅ WinRM funciona" -ForegroundColor Green
} catch {
    Write-Host "❌ WinRM no funciona" -ForegroundColor Red
}

# Puerto
$port = netstat -an | findstr ":5985"
if ($port) {
    Write-Host "✅ Puerto 5985 escuchando" -ForegroundColor Green
} else {
    Write-Host "❌ Puerto 5985 no escucha" -ForegroundColor Red
}

Write-Host "`n=== CONFIGURACIÓN COMPLETADA ===" -ForegroundColor Cyan
Write-Host "Ahora prueba desde Ansible:" -ForegroundColor Yellow
Write-Host "ansible-playbook playbooks/simple_windows_test.yml -i inventory/hosts.yml" -ForegroundColor White
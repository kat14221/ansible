# Script para verificar WinRM desde Windows
# Ejecutar como Administrador

Write-Host "=== VERIFICACIÓN COMPLETA WINRM ===" -ForegroundColor Cyan

# 1. Estado del servicio
Write-Host "`n[1] Estado del servicio WinRM:" -ForegroundColor Yellow
Get-Service WinRM | Format-Table Name, Status, StartType

# 2. Test local
Write-Host "`n[2] Test WSMan local:" -ForegroundColor Yellow
try {
    Test-WSMan -ComputerName localhost
    Write-Host "✅ WSMan funciona localmente" -ForegroundColor Green
} catch {
    Write-Host "❌ WSMan falla: $($_.Exception.Message)" -ForegroundColor Red
}

# 3. Listeners activos
Write-Host "`n[3] Listeners configurados:" -ForegroundColor Yellow
winrm enumerate winrm/config/listener

# 4. Configuración de servicio
Write-Host "`n[4] Configuración del servicio:" -ForegroundColor Yellow
winrm get winrm/config/service

# 5. Puertos en escucha
Write-Host "`n[5] Puertos en escucha:" -ForegroundColor Yellow
netstat -an | findstr ":5985"
netstat -an | findstr ":5986"

# 6. Usuario ansible
Write-Host "`n[6] Verificar usuario ansible:" -ForegroundColor Yellow
try {
    $user = Get-LocalUser -Name "ansible"
    Write-Host "Usuario: $($user.Name)" -ForegroundColor Green
    Write-Host "Habilitado: $($user.Enabled)" -ForegroundColor Green
    Write-Host "Descripción: $($user.Description)" -ForegroundColor Green
    
    # Verificar grupo
    $adminMembers = Get-LocalGroupMember -Group "Administrators"
    $isAdmin = $adminMembers | Where-Object {$_.Name -like "*ansible*"}
    if ($isAdmin) {
        Write-Host "✅ Usuario ansible es Administrador" -ForegroundColor Green
    } else {
        Write-Host "❌ Usuario ansible NO es Administrador" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Usuario ansible no encontrado" -ForegroundColor Red
}

# 7. Reglas de firewall
Write-Host "`n[7] Reglas de firewall para WinRM:" -ForegroundColor Yellow
$fwRules = Get-NetFirewallRule | Where-Object {$_.DisplayName -like "*WinRM*" -or $_.DisplayName -like "*5985*"}
if ($fwRules) {
    $fwRules | Format-Table DisplayName, Enabled, Direction, Action
} else {
    Write-Host "❌ No hay reglas específicas de firewall para WinRM" -ForegroundColor Red
}

# 8. IPv6 configuration
Write-Host "`n[8] Configuración IPv6:" -ForegroundColor Yellow
$ipv6 = Get-NetIPAddress -AddressFamily IPv6 | Where-Object {$_.IPAddress -like "2025:*"}
if ($ipv6) {
    Write-Host "✅ IPv6 configurado:" -ForegroundColor Green
    $ipv6 | Format-Table IPAddress, InterfaceAlias, AddressState
} else {
    Write-Host "❌ IPv6 2025:db8:101::11 no encontrado" -ForegroundColor Red
    Write-Host "Todas las direcciones IPv6:" -ForegroundColor Yellow
    Get-NetIPAddress -AddressFamily IPv6 | Format-Table IPAddress, InterfaceAlias
}

# 9. Test de autenticación
Write-Host "`n[9] Test de autenticación:" -ForegroundColor Yellow
try {
    # Intentar autenticar con el usuario ansible localmente
    $cred = New-Object System.Management.Automation.PSCredential("ansible", (ConvertTo-SecureString "Ansible123!" -AsPlainText -Force))
    $session = New-PSSession -ComputerName localhost -Credential $cred -ErrorAction Stop
    Remove-PSSession $session
    Write-Host "✅ Autenticación con usuario ansible funciona" -ForegroundColor Green
} catch {
    Write-Host "❌ Autenticación falla: $($_.Exception.Message)" -ForegroundColor Red
}

# 10. Comandos de reparación sugeridos
Write-Host "`n[10] Si hay problemas, ejecutar:" -ForegroundColor Yellow
Write-Host "winrm quickconfig -force" -ForegroundColor White
Write-Host "Enable-PSRemoting -Force" -ForegroundColor White
Write-Host "Set-Item WSMan:\localhost\Service\Auth\Basic `$true -Force" -ForegroundColor White
Write-Host "New-NetFirewallRule -DisplayName 'WinRM-HTTP-In' -Direction Inbound -Protocol TCP -LocalPort 5985 -Action Allow" -ForegroundColor White

Write-Host "`n=== VERIFICACIÓN COMPLETADA ===" -ForegroundColor Cyan
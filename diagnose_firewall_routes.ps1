Write-Host "=== DIAGNOSTICO FIREWALL WINRM ===" -ForegroundColor Cyan

Write-Host "`n1. Reglas firewall WinRM:" -ForegroundColor Yellow
Get-NetFirewallRule | Where-Object { $_.DisplayName -like "*WinRM*" -and $_.Enabled -eq "True" } | 
    Select-Object DisplayName, Direction, Action, Profile

Write-Host "`n2. Puertos abiertos en firewall:" -ForegroundColor Yellow  
Get-NetFirewallPortFilter | Where-Object { $_.LocalPort -eq 5985 } |
    Get-NetFirewallRule | Where-Object { $_.Enabled -eq "True" } |
    Select-Object DisplayName, Direction, Action

Write-Host "`n3. Test conectividad IPv6 local:" -ForegroundColor Yellow
Test-NetConnection -ComputerName "::1" -Port 5985

Write-Host "`n4. Test conectividad IPv6 externa (si hay router):" -ForegroundColor Yellow
Test-NetConnection -ComputerName "2025:db8:101::1" -Port 22 -InformationLevel Detailed

Write-Host "`n5. Tabla de rutas IPv6:" -ForegroundColor Yellow
Get-NetRoute -AddressFamily IPv6 | Where-Object { $_.DestinationPrefix -like "2025:db8:101::*" -or $_.DestinationPrefix -eq "::/0" }

Write-Host "`n=== COMPLETADO ===" -ForegroundColor Green
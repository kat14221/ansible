# Habilitar WinRM para IPv6 específicamente
Write-Host "=== HABILITANDO WINRM PARA IPv6 ===" -ForegroundColor Cyan

Write-Host "`n1. Configurar listener IPv6:" -ForegroundColor Yellow
winrm create winrm/config/Listener?Address=*+Transport=HTTP

Write-Host "`n2. Verificar listeners:" -ForegroundColor Yellow
winrm enumerate winrm/config/listener

Write-Host "`n3. Configurar firewall para IPv6:" -ForegroundColor Yellow
netsh advfirewall firewall add rule name="WinRM-HTTP-IPv6" dir=in action=allow protocol=TCP localport=5985 profile=any

Write-Host "`n4. Reiniciar WinRM:" -ForegroundColor Yellow
Restart-Service WinRM -Force

Write-Host "`n5. Test final IPv6:" -ForegroundColor Yellow
Start-Sleep -Seconds 3
Test-NetConnection -ComputerName "::1" -Port 5985

Write-Host "`n=== COMPLETADO ===" -ForegroundColor Green
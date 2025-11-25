# Configurar WinRM con timeouts extendidos
Write-Host "=== CONFIGURANDO WINRM TIMEOUTS EXTENDIDOS ===" -ForegroundColor Cyan

Write-Host "`n1. Configurar timeouts WinRM:" -ForegroundColor Yellow
winrm set winrm/config '@{MaxTimeoutms="300000"}'
winrm set winrm/config/Service '@{MaxConcurrentOperationsPerUser="100"}'
winrm set winrm/config/Service/Auth '@{Basic="true"}'
winrm set winrm/config/Listener?Address=*+Transport=HTTP '@{Port="5985";Hostname="";Enabled="true"}'

Write-Host "`n2. Configurar memoria y conexiones:" -ForegroundColor Yellow
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="1024"}'
winrm set winrm/config/winrs '@{MaxShellsPerUser="100"}'
winrm set winrm/config/winrs '@{MaxConcurrentUsers="100"}'

Write-Host "`n3. Verificar configuracion:" -ForegroundColor Yellow
winrm get winrm/config

Write-Host "`n4. Reiniciar servicio:" -ForegroundColor Yellow
Restart-Service WinRM -Force

Write-Host "`n=== COMPLETADO ===" -ForegroundColor Green
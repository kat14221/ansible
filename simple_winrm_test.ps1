Write-Host "=== DIAGNOSTICO WINRM SIMPLE ===" -ForegroundColor Cyan

Write-Host "`n1. Estado servicio WinRM:" -ForegroundColor Yellow
Get-Service WinRM

Write-Host "`n2. Test WSMan:" -ForegroundColor Yellow
Test-WSMan -ComputerName localhost

Write-Host "`n3. Puerto 5985 en escucha:" -ForegroundColor Yellow
netstat -an | findstr ":5985"

Write-Host "`n4. Usuario ansible:" -ForegroundColor Yellow
Get-LocalUser -Name "ansible"

Write-Host "`n5. IPv6 2025:" -ForegroundColor Yellow
Get-NetIPAddress -AddressFamily IPv6 | Where-Object {$_.IPAddress -like "2025:*"}

Write-Host "`n6. Test autenticacion local:" -ForegroundColor Yellow
$cred = New-Object System.Management.Automation.PSCredential("ansible", (ConvertTo-SecureString "Ansible123!" -AsPlainText -Force))
New-PSSession -ComputerName localhost -Credential $cred

Write-Host "`n=== COMPLETADO ===" -ForegroundColor Green
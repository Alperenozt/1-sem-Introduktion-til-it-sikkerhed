# Find systeminformation - Hostname og lokal IP-adresse

# Hent hostname
$hostname = $env:COMPUTERNAME
Write-Host "Hostname: $hostname"

# Hent lokal IP-adresse
$localIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*" -and $_.IPAddress -notlike "169.254.*"}).IPAddress

Write-Host "Lokal IP-adresse: $localIP"


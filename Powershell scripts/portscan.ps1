# Port Scanner - IT Security Assessment Tool
# Version: 1.0
# Purpose: Network security audit and open port detection

# CONFIGURATION
# Note: I produktion ville man scanne remote servere (f.eks. 192.168.1.10)
# Her scanner vi localhost til test/demo formål
$targetIP = "127.0.0.1"
$portRange = 1..1024

# Start banner
Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host " Port Scanner - Security Assessment Tool" -ForegroundColor White
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Target IP: $targetIP" -ForegroundColor Yellow
Write-Host "Port range: 1-1024" -ForegroundColor Yellow
Write-Host "Start time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Yellow
Write-Host "Operator: $env:USERNAME" -ForegroundColor Yellow
Write-Host "============================================`n" -ForegroundColor Cyan

# Results array
$openPorts = @()
$closedCount = 0

# Scan hver port
Write-Host "Scanning in progress...`n" -ForegroundColor Cyan

foreach ($port in $portRange) {
    # Progress bar
    $percent = ($port / 1024) * 100
    Write-Progress -Activity "Security Scan" -Status "Port $port" -PercentComplete $percent
    
    # Create TCP socket connection
    $tcpClient = New-Object System.Net.Sockets.TcpClient
    
    try {
        # Attempt connection
        $connection = $tcpClient.BeginConnect($targetIP, $port, $null, $null)
        $wait = $connection.AsyncWaitHandle.WaitOne(100, $false)
        
        if ($wait) {
            # Connection successful - port is open
            $tcpClient.EndConnect($connection)
            $openPorts += $port
            Write-Host "[OPEN] Port $port detected" -ForegroundColor Green
        } else {
            # Timeout - port is closed
            $closedCount++
        }
        
    } catch {
        # Error - port is closed or filtered
        $closedCount++
    } finally {
        # Clean up connection
        $tcpClient.Close()
    }
}

Write-Progress -Activity "Security Scan" -Completed

# Generate report
$endTime = Get-Date
Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host " Scan Report" -ForegroundColor White
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "End time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Yellow
Write-Host "Total ports scanned: 1024" -ForegroundColor White
Write-Host "Open ports found: $($openPorts.Count)" -ForegroundColor Green
Write-Host "Closed ports: $closedCount" -ForegroundColor Red

if ($openPorts.Count -gt 0) {
    Write-Host "`nOpen ports list:" -ForegroundColor Yellow
    foreach ($port in $openPorts) {
        # Add common service names
        $service = switch ($port) {
            21 { "FTP" }
            22 { "SSH" }
            23 { "Telnet" }
            25 { "SMTP" }
            80 { "HTTP" }
            110 { "POP3" }
            135 { "MS-RPC" }
            139 { "NetBIOS" }
            143 { "IMAP" }
            443 { "HTTPS" }
            445 { "SMB" }
            3306 { "MySQL" }
            3389 { "RDP" }
            5432 { "PostgreSQL" }
            8080 { "HTTP-Alt" }
            default { "Unknown" }
        }
        Write-Host "  Port $port - $service" -ForegroundColor White
    }
} else {
    Write-Host "`nNo open ports detected." -ForegroundColor Green
}

Write-Host "`n============================================" -ForegroundColor Cyan

# Save report to file
$reportFile = "portscan_report_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
$report = @"
Port Scanner - Security Assessment Report
==========================================
Target: $targetIP
Scan Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Operator: $env:USERNAME
Computer: $env:COMPUTERNAME

Scan Results:
- Total ports scanned: 1024
- Open ports: $($openPorts.Count)
- Closed ports: $closedCount

Open Ports Detected:
$($openPorts -join ', ')

Note: I et produktionsmiljø ville denne scan typisk køres mod
remote servere og netværksudstyr (ikke localhost).

End of Report
"@

$report | Out-File -FilePath $reportFile -Encoding UTF8
Write-Host "Report saved: $reportFile" -ForegroundColor Green
Write-Host ""
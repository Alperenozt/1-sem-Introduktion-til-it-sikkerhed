#!/bin/bash

# Automatisk Nmap Scanner
# Forfatter: [Dit navn]
# Dato: $(date +%Y-%m-%d)

echo "Automatisk Nmap Scanner"
echo "======================"

# Tjek om nmap er installeret
if ! command -v nmap &> /dev/null; then
    echo "❌ nmap ikke installeret!"
    echo "Installer med: sudo apt install nmap"
    exit 1
fi

# Spørg om target
echo ""
echo "Indtast target (IP eller hostname):"
echo "Eksempler: 192.168.1.1, localhost, scanme.nmap.org"
read target

if [ -z "$target" ]; then
    echo "❌ Ingen target angivet!"
    exit 1
fi

# Vælg scan type
echo ""
echo "Vælg scan type:"
echo "1) Quick scan (top 100 porte)"
echo "2) Normal scan (top 1000 porte)"
echo "3) Full scan (alle 65535 porte - langsomt!)"
echo "4) Service detection (identificer services)"
echo ""
read scan_type

# Log fil
log_file="$HOME/nmap_scan_$(date +%Y%m%d_%H%M%S).txt"

echo ""
echo "🎯 Target: $target"
echo "📝 Logger til: $log_file"
echo ""

# Log header
echo "=== NMAP SCAN $(date) ===" > "$log_file"
echo "Target: $target" >> "$log_file"
echo "" >> "$log_file"

case $scan_type in
    1)
        echo "🚀 Quick Scan (top 100 porte)..."
        echo ""
        
        nmap --top-ports 100 "$target" | tee -a "$log_file"
        ;;
        
    2)
        echo "🔍 Normal Scan (top 1000 porte)..."
        echo ""
        
        nmap "$target" | tee -a "$log_file"
        ;;
        
    3)
        echo "💥 Full Scan (alle porte - dette tager tid!)..."
        echo ""
        
        nmap -p- "$target" | tee -a "$log_file"
        ;;
        
    4)
        echo "🔬 Service Detection Scan..."
        echo ""
        
        nmap -sV "$target" | tee -a "$log_file"
        ;;
        
    *)
        echo "❌ Ugyldigt valg - bruger normal scan"
        nmap "$target" | tee -a "$log_file"
        ;;
esac

echo ""
echo ""
echo "📊 KUN ÅBNE PORTE:"
echo "================="

# Filtrer kun åbne porte fra output
grep "open" "$log_file" | while read line; do
    port=$(echo "$line" | awk '{print $1}')
    state=$(echo "$line" | awk '{print $2}')
    service=$(echo "$line" | awk '{print $3}')
    
    echo "✅ Port: $port | Status: $state | Service: $service"
done

# Tæl åbne porte
open_count=$(grep -c "open" "$log_file")

echo ""
echo "📈 SAMMENDRAG:"
echo "============="
echo "Target: $target"
echo "Åbne porte fundet: $open_count"
echo "Log fil: $log_file"

if [ "$open_count" -gt 0 ]; then
    echo ""
    echo "🔍 ALMINDELIGE PORTE FUNDET:"
    echo "=========================="
    
    # Tjek for specifikke porte
    if grep -q "22/tcp.*open" "$log_file"; then
        echo "🔓 Port 22 (SSH) - Remote access"
    fi
    
    if grep -q "80/tcp.*open" "$log_file"; then
        echo "🌐 Port 80 (HTTP) - Webserver"
    fi
    
    if grep -q "443/tcp.*open" "$log_file"; then
        echo "🔒 Port 443 (HTTPS) - Sikker webserver"
    fi
    
    if grep -q "21/tcp.*open" "$log_file"; then
        echo "📁 Port 21 (FTP) - File transfer"
    fi
    
    if grep -q "3306/tcp.*open" "$log_file"; then
        echo "💾 Port 3306 (MySQL) - Database"
    fi
    
    if grep -q "3389/tcp.*open" "$log_file"; then
        echo "🖥️  Port 3389 (RDP) - Remote Desktop"
    fi
fi

echo ""
echo "💡 NMAP KOMMANDOER:"
echo "=================="
echo "# Quick scan:"
echo "nmap --top-ports 100 $target"
echo ""
echo "# Service detection:"
echo "nmap -sV $target"
echo ""
echo "# OS detection (kræver sudo):"
echo "sudo nmap -O $target"
echo ""
echo "# Aggressive scan:"
echo "sudo nmap -A $target"
echo ""
echo "# Stealth scan:"
echo "sudo nmap -sS $target"

echo ""
echo "⚠️  ETIK:"
echo "========"
echo "- Kun scan egne systemer eller med tilladelse"
echo "- Uautoriseret scanning kan være ulovligt"
echo "- Brug ansvarligt til sikkerhedstest"

echo ""
echo "Scan afsluttet: $(date)"

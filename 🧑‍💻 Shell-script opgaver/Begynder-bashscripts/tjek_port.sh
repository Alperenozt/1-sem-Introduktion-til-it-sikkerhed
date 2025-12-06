#!/bin/bash

# Script til at tjekke om en port er åben
# Forfatter: [Dit navn]
# Dato: $(date +%Y-%m-%d)

echo "Port-tjekker Script"
echo "=================="

# Bed brugeren om at indtaste portnummer
echo "Indtast portnummer der skal tjekkes (eller tryk Enter for port 22):"
read port

# Hvis ingen input, brug port 22 (SSH)
if [ -z "$port" ]; then
    port=22
    echo "Bruger standard port: 22 (SSH)"
fi

echo ""
echo "Tjekker port: $port"
echo "=================="

# Tjek om netstat findes
if command -v netstat &> /dev/null; then
    echo "Bruger netstat kommando:"
    echo "------------------------"
    
    # Tjek med netstat
    netstat_result=$(netstat -tuln | grep ":$port ")
    
    if [ -n "$netstat_result" ]; then
        echo "✅ Port $port er ÅBEN:"
        echo "$netstat_result"
        
        # Vis hvilken service der lytter
        echo ""
        echo "Service information:"
        netstat -tulnp | grep ":$port " 2>/dev/null
    else
        echo "❌ Port $port er LUKKET eller ikke i brug"
    fi
    
    echo ""
fi

# Tjek om ss findes (moderne alternativ)
if command -v ss &> /dev/null; then
    echo "Bruger ss kommando (moderne metode):"
    echo "------------------------------------"
    
    # Tjek med ss
    ss_result=$(ss -tuln | grep ":$port ")
    
    if [ -n "$ss_result" ]; then
        echo "✅ Port $port er ÅBEN:"
        echo "$ss_result"
        
        # Vis hvilken proces der lytter
        echo ""
        echo "Proces information:"
        ss -tulnp | grep ":$port " 2>/dev/null
    else
        echo "❌ Port $port er LUKKET eller ikke i brug"
    fi
    
    echo ""
fi

# Hvis hverken netstat eller ss findes
if ! command -v netstat &> /dev/null && ! command -v ss &> /dev/null; then
    echo "❌ FEJL: Hverken netstat eller ss er installeret!"
    echo "Installer med: sudo apt install net-tools"
fi

echo "Almindelige porte:"
echo "=================="
echo "22  - SSH"
echo "80  - HTTP (web)"
echo "443 - HTTPS (sikker web)"
echo "21  - FTP"
echo "25  - SMTP (email)"
echo "3306 - MySQL"
echo "5432 - PostgreSQL"

echo ""
echo "Port-tjek afsluttet: $(date)"

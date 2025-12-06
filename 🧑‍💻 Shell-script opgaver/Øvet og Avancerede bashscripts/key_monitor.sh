#!/bin/bash

# EDUCATIONAL KEYLOGGER SIMULATION
# KUN til cybersecurity uddannelse på egen maskine!
# Forfatter: [Dit navn]
# Dato: $(date +%Y-%m-%d)

echo "⚠️  EDUCATIONAL KEYLOGGER SIMULATION ⚠️"
echo "======================================"
echo "Dette script demonstrerer keylogging koncepter"
echo "KUN til cybersecurity læring på egen maskine!"
echo ""

# Advarsel
echo "🚨 ETISK ADVARSEL:"
echo "================="
echo "- Kun til egen brug og læring"
echo "- Aldrig brug på andres systemer"
echo "- Ulovligt at bruge uden tilladelse"
echo "- Kan være strafbart"
echo ""

echo "Fortsæt? (skriv JA):"
read confirm

if [ "$confirm" != "JA" ]; then
    echo "Script afbrudt"
    exit 0
fi

# Log fil
log_file="$HOME/key_log_$(date +%Y%m%d_%H%M%S).txt"

echo ""
echo "📝 Logger til: $log_file"
echo ""
echo "🎯 SIMPEL METODE: Input monitoring"
echo "=================================="
echo "Skriv noget (tekst bliver logget):"
echo "Tryk Ctrl+C for at stoppe"
echo ""

# Log header
echo "=== KEY LOG STARTET $(date) ===" > "$log_file"
echo "" >> "$log_file"

# Simpel input læsning (educational demonstration)
while true; do
    # Læs input linje for linje
    read -p "> " input
    
    if [ -n "$input" ]; then
        timestamp=$(date +"%Y-%m-%d %H:%M:%S")
        
        # Log til fil
        echo "[$timestamp] $input" >> "$log_file"
        
        # Vis at det blev logget
        echo "  ✅ Logget: ${#input} tegn"
    fi
done

# Cleanup ved Ctrl+C
trap 'echo ""; echo "Keylogger stoppet"; echo "Log gemt i: $log_file"; exit 0' INT

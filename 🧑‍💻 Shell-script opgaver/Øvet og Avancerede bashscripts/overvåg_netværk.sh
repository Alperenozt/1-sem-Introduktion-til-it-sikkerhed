#!/bin/bash

# Script til at overvåge netværksforbindelser (ny simpel version)
# Forfatter: [Dit navn]  
# Dato: $(date +%Y-%m-%d)

echo "Netværks Logger"
echo "==============="

# Log fil
log_file="$HOME/netværk_aktivitet.log"

echo "Logger alle netværk aktivitet til: $log_file"
echo ""

# Opret log fil med start besked
echo "=== NETVÆRK OVERVÅGNING STARTET $(date) ===" >> "$log_file"
echo "" >> "$log_file"

echo "🔍 Logger netværksaktivitet hvert 10. sekund..."
echo "Tryk Ctrl+C for at stoppe"
echo ""

# Simpel overvågning - logger alt hver gang
while true; do
    echo "$(date): Tjekker forbindelser..." | tee -a "$log_file"
    
    # Kun etablerede forbindelser (det basale)
    echo "AKTIVE FORBINDELSER:" >> "$log_file"
    ss -t state established >> "$log_file" 2>&1
    echo "---" >> "$log_file"
    echo "" >> "$log_file"
    
    echo "✅ Data logget kl. $(date +%H:%M:%S)"
    
    sleep 10
done

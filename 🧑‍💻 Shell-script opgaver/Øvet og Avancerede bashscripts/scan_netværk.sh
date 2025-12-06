#!/bin/bash

# Script til at scanne subnet for aktive værter
# Forfatter: [Dit navn]
# Dato: $(date +%Y-%m-%d)

echo "Netværks Scanner"
echo "==============="
echo "Scanner subnet for aktive computere..."

# Standard subnet
DEFAULT_SUBNET="192.168.1"

# Spørg brugeren om subnet
echo ""
echo "Indtast subnet at scanne (f.eks. 192.168.1):"
echo "Tryk Enter for standard: $DEFAULT_SUBNET"
read subnet_input

# Hvis ingen input, brug standard
if [ -z "$subnet_input" ]; then
    subnet=$DEFAULT_SUBNET
else
    subnet="$subnet_input"
fi

echo ""
echo "🔍 Scanner: ${subnet}.1-254"
echo "Dette kan tage 1-2 minutter..."
echo ""

# Opret resultat liste
aktive_hosts=()

echo "AKTIVE VÆRTER FUNDET:"
echo "===================="

# Scan hver IP adresse (1-254)
for i in {1..254}; do
    ip="${subnet}.${i}"
    
    # Vis progress hver 50. IP
    if [ $((i % 50)) -eq 0 ]; then
        echo "Scanner... ${ip}"
    fi
    
    # Ping med timeout på 1 sekund, kun 1 ping
    if ping -c 1 -W 1 "$ip" >/dev/null 2>&1; then
        # Host er aktiv - vis resultat
        echo ""
        echo "✅ AKTIV: $ip"
        
        # Prøv at få hostname
        hostname=$(timeout 2 nslookup "$ip" 2>/dev/null | grep "name =" | cut -d= -f2 | awk '{print $1}' | sed 's/\.$//')
        
        if [ -n "$hostname" ]; then
            echo "   📛 Navn: $hostname"
        else
            echo "   📛 Navn: Ikke fundet"
        fi
        
        # Prøv at gætte hvad det er baseret på IP
        case "$i" in
            1)
                echo "   🌐 Sandsynligvis: Router/Gateway"
                ;;
            2-10)
                echo "   🖥️  Sandsynligvis: Router eller server"
                ;;
            100-200)
                echo "   💻 Sandsynligvis: Computer/laptop"
                ;;
            *)
                echo "   🔍 Type: Ukendt enhed"
                ;;
        esac
        
        # Tilføj til liste
        aktive_hosts+=("$ip")
    fi
done

echo ""
echo ""
echo "📊 SAMMENDRAG:"
echo "============="

# Vis antal fundne værter
antal_aktive=${#aktive_hosts[@]}
echo "Aktive værter fundet: $antal_aktive"

if [ "$antal_aktive" -gt 0 ]; then
    echo ""
    echo "Liste over aktive IP'er:"
    for host in "${aktive_hosts[@]}"; do
        echo "  • $host"
    done
    
    echo ""
    echo "💡 NÆSTE SKRIDT:"
    echo "==============="
    echo "For hver aktiv IP kan du:"
    echo ""
    echo "# Se åbne porte:"
    echo "nmap -p 1-1000 IP_ADRESSE"
    echo ""
    echo "# Få mere info:"
    echo "nmap -A IP_ADRESSE"
    echo ""
    echo "# Tjek specifik port:"
    echo "nc -zv IP_ADRESSE 22    # SSH"
    echo "nc -zv IP_ADRESSE 80    # HTTP"
    echo "nc -zv IP_ADRESSE 443   # HTTPS"
    
else
    echo ""
    echo "❌ Ingen aktive værter fundet"
    echo ""
    echo "🔍 TROUBLESHOOTING:"
    echo "=================="
    echo "- Tjek at du er på det rigtige netværk"
    echo "- Prøv dit eget netværk: $(ip route | grep default | awk '{print $3}' | cut -d. -f1-3)"
    echo "- Nogle enheder blokerer ping (firewalls)"
fi

# Vis dit eget netværk
echo ""
echo "📡 DIT NETVÆRK:"
echo "=============="
echo "Din IP: $(hostname -I | awk '{print $1}')"
echo "Gateway: $(ip route | grep default | awk '{print $3}')"
echo "Netværk: $(ip route | grep default | awk '{print $3}' | cut -d. -f1-3)"

echo ""
echo "⚠️  SIKKERHED:"
echo "============="
echo "- Brug kun på dit eget netværk"
echo "- Netværksscanning kan være ulovligt på andre netværk"
echo "- Scan kan blive detekteret af firewalls/IDS"

echo ""
echo "Scanner færdig: $(date)"

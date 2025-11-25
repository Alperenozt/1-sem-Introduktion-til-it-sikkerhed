#!/bin/bash

# Script til at udtrække IP-adresser fra webserver logs
# Forfatter: [Dit navn]
# Dato: $(date +%Y-%m-%d)

echo "Webserver Log IP Udtræker"
echo "========================="

# Spørg om log-fil
echo "Indtast sti til log-fil (eller tryk Enter for standard Apache log):"
echo "Standard: /var/log/apache2/access.log"
read log_file_input

# Sæt standard log-fil
if [ -z "$log_file_input" ]; then
    log_file="/var/log/apache2/access.log"
else
    log_file="$log_file_input"
fi

# Tjek om filen findes
if [ ! -f "$log_file" ]; then
    echo ""
    echo "❌ Log-fil ikke fundet: $log_file"
    echo ""
    echo "🔍 Leder efter almindelige log-filer..."
    
    # Søg efter log-filer
    possible_logs=(
        "/var/log/apache2/access.log"
        "/var/log/apache2/access.log.1"
        "/var/log/nginx/access.log"
        "/var/log/httpd/access_log"
        "/var/log/nginx/access.log.1"
    )
    
    echo "Mulige log-filer på systemet:"
    for possible_log in "${possible_logs[@]}"; do
        if [ -f "$possible_log" ]; then
            echo "✅ Fundet: $possible_log"
        fi
    done
    
    # Opret test-log hvis ingen findes
    echo ""
    echo "💡 Ingen log-filer fundet. Opretter test-log..."
    log_file="$HOME/test_access.log"
    
    cat > "$log_file" << 'EOF'
192.168.1.1 - - [01/Dec/2025:10:00:00 +0000] "GET / HTTP/1.1" 200 2326
10.0.0.5 - - [01/Dec/2025:10:01:00 +0000] "GET /index.html HTTP/1.1" 200 1024
192.168.1.1 - - [01/Dec/2025:10:02:00 +0000] "GET /about.html HTTP/1.1" 200 512
203.0.113.10 - - [01/Dec/2025:10:03:00 +0000] "GET /contact HTTP/1.1" 404 196
10.0.0.5 - - [01/Dec/2025:10:04:00 +0000] "POST /login HTTP/1.1" 302 0
198.51.100.22 - - [01/Dec/2025:10:05:00 +0000] "GET /admin HTTP/1.1" 403 162
192.168.1.100 - - [01/Dec/2025:10:06:00 +0000] "GET /images/logo.png HTTP/1.1" 200 5432
203.0.113.10 - - [01/Dec/2025:10:07:00 +0000] "GET /products HTTP/1.1" 200 3456
192.168.1.1 - - [01/Dec/2025:10:08:00 +0000] "GET /services HTTP/1.1" 200 2234
EOF
    
    echo "Test-log oprettet: $log_file"
fi

# Tjek læserettigheder
if [ ! -r "$log_file" ]; then
    echo "❌ Ingen læserettigheder til: $log_file"
    echo "Prøv med: sudo $0"
    exit 1
fi

echo ""
echo "📊 Analyserer log-fil: $log_file"
echo "================================"

# Vis log-fil info
file_size=$(du -h "$log_file" | cut -f1)
line_count=$(wc -l < "$log_file")

echo "Fil størrelse: $file_size"
echo "Antal linjer: $line_count"

# Vis første par linjer som eksempel
echo ""
echo "📄 Log-fil eksempel (første 3 linjer):"
echo "======================================="
head -3 "$log_file"

echo ""
echo "🔍 UDTRÆKKER IP-ADRESSER..."
echo "=========================="

# Udtræk IP-adresser (første felt i hver linje)
echo "Alle IP-adresser fundet:"
all_ips=$(awk '{print $1}' "$log_file")
echo "$all_ips"

echo ""
echo "📋 UNIKKE IP-ADRESSER:"
echo "====================="

# Udtræk unikke IP'er og tæl dem
unique_ips=$(awk '{print $1}' "$log_file" | sort | uniq)
echo "$unique_ips"

echo ""
echo "📊 IP STATISTIK:"
echo "==============="

# Tæl antal unikke IP'er
unique_count=$(echo "$unique_ips" | wc -l)
total_count=$(echo "$all_ips" | wc -l)

echo "Unikke IP-adresser: $unique_count"
echo "Totale requests: $total_count"

echo ""
echo "🏆 TOP 5 MEST AKTIVE IP'ER:"
echo "=========================="

# Tæl requests per IP og sorter
awk '{print $1}' "$log_file" | sort | uniq -c | sort -rn | head -5 | while read count ip; do
    echo "$ip: $count requests"
done

echo ""
echo "🌍 IP ANALYSE:"
echo "============="

# Analyser IP-ranges
echo "$unique_ips" | while read ip; do
    # Check IP type
    if echo "$ip" | grep -q "^192\.168\."; then
        echo "$ip - 🏠 Lokalt netværk (privat)"
    elif echo "$ip" | grep -q "^10\."; then
        echo "$ip - 🏠 Lokalt netværk (privat)" 
    elif echo "$ip" | grep -q "^172\.(1[6-9]|2[0-9]|3[01])\."; then
        echo "$ip - 🏠 Lokalt netværk (privat)"
    elif echo "$ip" | grep -q "^127\."; then
        echo "$ip - 🖥️  Localhost"
    else
        echo "$ip - 🌐 Internet (offentlig)"
    fi
done

# Gem resultater til fil
output_file="$HOME/unique_ips_$(date +%Y%m%d_%H%M%S).txt"
echo "$unique_ips" > "$output_file"

echo ""
echo "💾 RESULTATER GEMT:"
echo "=================="
echo "Unikke IP'er gemt i: $output_file"

# Vis potentielle sikkerhedsbekymringer
echo ""
echo "🔒 SIKKERHEDSANALYSE:"
echo "===================="

# Check for mistænkelige mønstre
suspicious_ips=$(awk '{print $1}' "$log_file" | sort | uniq -c | sort -rn | head -1 | awk '{if($1>10) print $2 " (" $1 " requests)"}')

if [ -n "$suspicious_ips" ]; then
    echo "⚠️  Mistænkelig højt traffik fra: $suspicious_ips"
    echo "   Dette kunne indikere:"
    echo "   - DDoS angreb"
    echo "   - Bot aktivitet"
    echo "   - Web scraping"
else
    echo "✅ Ingen mistænkelige IP mønstre fundet"
fi

# Check for fejlede requests
error_requests=$(grep " 40[0-9] \| 50[0-9] " "$log_file" | awk '{print $1}' | sort | uniq | wc -l)
echo ""
echo "🚫 IP'er med fejlede requests: $error_requests"

echo ""
echo "💡 NYTTIGE KOMMANDOER:"
echo "===================="
echo "# Se alle requests fra en IP:"
echo "grep 'IP_ADRESSE' $log_file"
echo ""
echo "# Blokér IP i firewall:"
echo "sudo iptables -A INPUT -s IP_ADRESSE -j DROP"
echo ""
echo "# Analyser bruger-agents:"
echo "awk '{print \$12\" \"\$13\" \"\$14}' $log_file | sort | uniq -c | sort -rn"

echo ""
echo "Analyse afsluttet: $(date)"

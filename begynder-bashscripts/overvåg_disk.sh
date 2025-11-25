#!/bin/bash

# Script til overvågning af diskplads
# Forfatter: [Dit navn]
# Dato: $(date +%Y-%m-%d)

echo "Diskplads Overvågning"
echo "===================="

# Advarselsgrænse i procent
WARNING_THRESHOLD=10

echo "Advarselsgrænse sat til: ${WARNING_THRESHOLD}% ledig plads"
echo ""

# Vis alle monterede filesystemer
echo "Nuværende diskplads oversigt:"
echo "============================"
df -h | grep -E '^/dev/'

echo ""
echo "Tjekker alle partitioner..."
echo "=========================="

# Flag til at tracke om der er advarsler
warnings_found=false

# Loop gennem alle monterede filesystemer
df -h | grep -E '^/dev/' | while read filesystem size used avail percent mountpoint; do
    # Fjern % tegnet fra procent og konverter til tal
    usage_percent=$(echo $percent | sed 's/%//')
    
    # Beregn ledig plads procent
    free_percent=$((100 - usage_percent))
    
    echo "Tjekker: $mountpoint"
    echo "  Filesystem: $filesystem"
    echo "  Størrelse: $size"
    echo "  Brugt: $used ($usage_percent%)"
    echo "  Ledig: $avail (${free_percent}%)"
    
    # Tjek om ledig plads er under grænsen
    if [ $free_percent -lt $WARNING_THRESHOLD ]; then
        echo "  🚨 ADVARSEL: Kun ${free_percent}% ledig plads tilbage!"
        echo "  💾 Kritisk lav diskplads på $mountpoint"
        warnings_found=true
    else
        echo "  ✅ OK: ${free_percent}% ledig plads"
    fi
    
    echo ""
done

echo "Detaljeret analyse af root partition (/):"
echo "========================================"

# Specifik tjek af root partition
root_stats=$(df -h / | tail -n 1)
echo "$root_stats"

# Udtræk data for root partition
root_usage=$(df / | tail -n 1 | awk '{print $5}' | sed 's/%//')
root_free=$((100 - root_usage))

if [ $root_free -lt $WARNING_THRESHOLD ]; then
    echo ""
    echo "🚨🚨🚨 KRITISK ADVARSEL 🚨🚨🚨"
    echo "Root partition (/) har kun ${root_free}% ledig plads!"
    echo ""
    echo "Anbefalede handlinger:"
    echo "- Ryd op i /tmp: sudo rm -rf /tmp/*"
    echo "- Tøm papirkurv"
    echo "- Fjern gamle logfiler: sudo journalctl --vacuum-time=7d"
    echo "- Fjern pakke-cache: sudo apt clean"
    echo "- Find store filer: du -h / | sort -hr | head -20"
else
    echo "✅ Root partition OK: ${root_free}% ledig plads"
fi

echo ""
echo "Top 10 største mapper i hjemmemappe:"
echo "==================================="
du -sh $HOME/* 2>/dev/null | sort -hr | head -10

echo ""
echo "Diskplads tjek afsluttet: $(date)"

#!/bin/bash

# Script til at finde world-writable filer (simpel version)
# Forfatter: [Dit navn]
# Dato: $(date +%Y-%m-%d)

echo "Find Farlige Filer"
echo "=================="
echo "Søger efter filer som alle kan ændre..."

# Spørg hvor der skal søges
echo ""
echo "Hvor skal jeg søge?"
echo "1) Kun i din hjemmemappe (sikkert)"
echo "2) Hele computeren (kræver sudo)"
echo ""
echo "Indtast valg (1 eller 2):"
read valg

# Sæt søgesti
if [ "$valg" = "1" ]; then
    search_path="$HOME"
    echo "Søger i: $HOME"
elif [ "$valg" = "2" ]; then
    search_path="/"
    echo "Søger i hele systemet..."
    echo "Dette kan tage lang tid!"
else
    echo "Ugyldigt valg!"
    exit 1
fi

echo ""
echo "🔍 Starter søgning..."
echo "===================="

# Find world-writable filer
echo ""
echo "FILER ALLE KAN ÆNDRE:"
echo "===================="

# Simpel find kommando
find "$search_path" -type f -perm -002 2>/dev/null | while read fil; do
    echo ""
    echo "⚠️  FARLIG FIL: $fil"
    
    # Vis simple info
    info=$(ls -lh "$fil")
    echo "   Tilladelser: $(echo $info | awk '{print $1}')"
    echo "   Ejer: $(echo $info | awk '{print $3}')"
    echo "   Størrelse: $(echo $info | awk '{print $5}')"
    
    # Simpel sikkerhedscheck
    if echo "$fil" | grep -q "/bin/\|/sbin/\|/etc/"; then
        echo "   🚨 MEGET FARLIG! Dette er en systemfil!"
    elif echo "$fil" | grep -q "/tmp/"; then
        echo "   💡 OK: Temp-fil (normal)"
    else
        echo "   🔍 TJEK: Undersøg om denne fil skal kunne ændres"
    fi
done

echo ""
echo ""
echo "MAPPER ALLE KAN ÆNDRE:"
echo "====================="

# Find world-writable mapper  
find "$search_path" -type d -perm -002 2>/dev/null | head -10 | while read mappe; do
    echo ""
    echo "📂 MAPPE: $mappe"
    
    info=$(ls -ld "$mappe")
    echo "   Tilladelser: $(echo $info | awk '{print $1}')"
    echo "   Ejer: $(echo $info | awk '{print $3}')"
    
    if echo "$mappe" | grep -q "/tmp"; then
        echo "   ✅ OK: Temp-mappe (normal)"
    else
        echo "   ⚠️  TJEK: Skal alle kunne skrive her?"
    fi
done

# Tæl resultater
echo ""
echo ""
echo "SAMMENDRAG:"
echo "==========="

fil_antal=$(find "$search_path" -type f -perm -002 2>/dev/null | wc -l)
mappe_antal=$(find "$search_path" -type d -perm -002 2>/dev/null | wc -l)

echo "Farlige filer fundet: $fil_antal"
echo "Farlige mapper fundet: $mappe_antal"

if [ "$fil_antal" -gt 0 ] || [ "$mappe_antal" -gt 0 ]; then
    echo ""
    echo "HVORDAN RETTER MAN DET:"
    echo "======================"
    echo "For at fjerne farlige tilladelser:"
    echo ""
    echo "chmod o-w filnavn     # Fjern 'alle kan skrive'"
    echo "chmod o-w mappenavn   # Det samme for mapper"
    echo ""
    echo "Eksempel:"
    echo "chmod o-w /home/kali/farlig_fil.txt"
else
    echo ""
    echo "✅ GODT! Ingen farlige filer fundet!"
fi

echo ""
echo "Søgning færdig: $(date)"

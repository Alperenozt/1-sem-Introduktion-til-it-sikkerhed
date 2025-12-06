#!/bin/bash

# Script til at finde setuid-binaries
# Forfatter: [Dit navn]
# Dato: $(date +%Y-%m-%d)

echo "SetUID Binary Finder"
echo "===================="
echo "Søger efter filer med setuid-bit sat..."

echo ""
echo "💡 HVAD ER SETUID?"
echo "=================="
echo "SetUID = Set User ID"
echo "Filer der kører med ejers rettigheder (ofte root)"
echo "Eksempel: 'ping' kører som root selvom du ikke er root"

echo ""
echo "🔍 STARTER SØGNING..."
echo "===================="
echo "Dette kan tage et minut..."

# Log fil
log_file="$HOME/setuid_binaries.log"
echo "Logger til: $log_file"

# Skriv header til log
echo "=== SETUID BINARIES FUNDET $(date) ===" > "$log_file"
echo "" >> "$log_file"

echo ""
echo "SETUID FILER FUNDET:"
echo "==================="

# Find setuid filer på hele systemet
find / -type f -perm -4000 2>/dev/null | while read fil; do
    echo ""
    echo "🔑 SETUID: $fil"
    
    # Få filinfo
    info=$(ls -lah "$fil" 2>/dev/null)
    ejer=$(echo "$info" | awk '{print $3}')
    tilladelser=$(echo "$info" | awk '{print $1}')
    størrelse=$(echo "$info" | awk '{print $5}')
    
    echo "   Ejer: $ejer"
    echo "   Tilladelser: $tilladelser"
    echo "   Størrelse: $størrelse"
    
    # Log til fil
    echo "SETUID: $fil" >> "$log_file"
    echo "  Ejer: $ejer | Tilladelser: $tilladelser | Størrelse: $størrelse" >> "$log_file"
    
    # Sikkerhedsvurdering
    case "$fil" in
        */bin/ping|*/bin/ping6)
            echo "   ✅ NORMAL: Ping kommando"
            ;;
        */bin/sudo|*/usr/bin/sudo)
            echo "   ✅ NORMAL: Sudo kommando"
            ;;
        */bin/su)
            echo "   ✅ NORMAL: Su kommando"
            ;;
        */bin/passwd|*/usr/bin/passwd)
            echo "   ✅ NORMAL: Password kommando"
            ;;
        */bin/mount|*/usr/bin/mount)
            echo "   ✅ NORMAL: Mount kommando"
            ;;
        */tmp/*|*/var/tmp/*)
            echo "   🚨 MISTÆNKELIGT: Temp-mappe fil!"
            echo "     MISTÆNKELIGT: $fil" >> "$log_file"
            ;;
        */home/*)
            echo "   ⚠️  TJEK: Bruger-mappe fil"
            echo "     TJEK: $fil" >> "$log_file"
            ;;
        *)
            echo "   🔍 UNDERSØG: Ukendt setuid-fil"
            echo "     UNDERSØG: $fil" >> "$log_file"
            ;;
    esac
    
    # Vis hvad filen gør
    file_type=$(file "$fil" 2>/dev/null | cut -d: -f2)
    echo "   Type:$file_type"
    
    echo "" >> "$log_file"
done

# Tæl resultater
echo ""
echo ""
echo "📊 SAMMENDRAG:"
echo "============="

total_setuid=$(find / -type f -perm -4000 2>/dev/null | wc -l)
echo "Totale setuid-filer fundet: $total_setuid"

# Vis fordeling
echo ""
echo "FORDELING PER EJER:"
echo "=================="
find / -type f -perm -4000 2>/dev/null | while read fil; do
    stat -c "%U" "$fil" 2>/dev/null
done | sort | uniq -c | sort -rn

echo "" >> "$log_file"
echo "Total setuid-filer: $total_setuid" >> "$log_file"

echo ""
echo "🔒 SIKKERHEDSTIPS:"
echo "=================="
echo "1. Tjek regelmæssigt for nye setuid-filer"
echo "2. Filer i /tmp/ eller hjemmemapper er mistænkelige"
echo "3. Ukendte setuid-filer kan være malware"
echo "4. Standard system-kommandoer er normalt OK"

echo ""
echo "💡 KOMMANDOER:"
echo "=============="
echo "# Fjern setuid-bit:"
echo "sudo chmod u-s filnavn"
echo ""
echo "# Tilføj setuid-bit (farligt!):"
echo "sudo chmod u+s filnavn"
echo ""
echo "# Tjek specifik fil:"
echo "ls -la filnavn"

echo ""
echo "✅ Søgning afsluttet: $(date)"
echo "📄 Fuld log gemt i: $log_file"

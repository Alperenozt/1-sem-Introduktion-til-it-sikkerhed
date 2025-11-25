#!/bin/bash

# Script til fil hash generering og integritetsjek
# Forfatter: [Dit navn]
# Dato: $(date +%Y-%m-%d)

echo "Fil Hash & Integritetsjekker"
echo "============================"

# Tjek om sha256sum findes
if ! command -v sha256sum &> /dev/null; then
    echo "❌ FEJL: sha256sum ikke fundet!"
    echo "Prøv at installere: sudo apt install coreutils"
    exit 1
fi

# Spørg brugeren om handling
echo "Vælg handling:"
echo "1) Generer hash for en fil"
echo "2) Tjek integritet af en fil"
echo "3) Batch-proces flere filer"
echo ""
echo "Indtast valg (1-3):"
read choice

case $choice in
    1)
        echo ""
        echo "=== GENERER HASH ==="
        echo "Indtast filsti:"
        read filepath
        
        # Tjek om filen findes
        if [ ! -f "$filepath" ]; then
            echo "❌ FEJL: Filen '$filepath' findes ikke!"
            exit 1
        fi
        
        # Tjek om filen er læsbar
        if [ ! -r "$filepath" ]; then
            echo "❌ FEJL: Ingen læserettigheder til '$filepath'"
            exit 1
        fi
        
        echo ""
        echo "📁 Fil information:"
        echo "=================="
        ls -lh "$filepath"
        echo "Filtype: $(file "$filepath")"
        
        echo ""
        echo "🔐 Genererer SHA256 hash..."
        echo "=========================="
        
        # Generer hash
        hash_output=$(sha256sum "$filepath")
        hash_value=$(echo "$hash_output" | cut -d' ' -f1)
        filename=$(basename "$filepath")
        
        echo "Hash: $hash_value"
        echo "Fil:  $filename"
        
        # Gem hash til fil
        hash_file="${filepath}.sha256"
        echo "$hash_output" > "$hash_file"
        echo ""
        echo "💾 Hash gemt i: $hash_file"
        
        # Vis hash fil indhold
        echo ""
        echo "📄 Hash fil indhold:"
        cat "$hash_file"
        
        ;;
        
    2)
        echo ""
        echo "=== TJEK INTEGRITET ==="
        echo "Indtast filsti til hash-fil (.sha256):"
        read hash_filepath
        
        # Tjek om hash-filen findes
        if [ ! -f "$hash_filepath" ]; then
            echo "❌ FEJL: Hash-filen '$hash_filepath' findes ikke!"
            exit 1
        fi
        
        echo ""
        echo "📖 Læser hash-fil..."
        echo "==================="
        cat "$hash_filepath"
        
        # Udtræk original filnavn fra hash-fil
        original_file=$(awk '{print $2}' "$hash_filepath")
        stored_hash=$(awk '{print $1}' "$hash_filepath")
        
        echo ""
        echo "Original fil: $original_file"
        echo "Gemt hash:    $stored_hash"
        
        # Tjek om original fil stadig findes
        if [ ! -f "$original_file" ]; then
            echo "❌ FEJL: Original fil '$original_file' ikke fundet!"
            exit 1
        fi
        
        echo ""
        echo "🔍 Beregner nuværende hash..."
        echo "==========================="
        
        # Beregn nuværende hash
        current_hash=$(sha256sum "$original_file" | cut -d' ' -f1)
        echo "Nuværende hash: $current_hash"
        
        # Sammenlign hashes
        echo ""
        echo "🔍 INTEGRITETSJEK:"
        echo "================="
        
        if [ "$stored_hash" = "$current_hash" ]; then
            echo "✅ SUCCESS: Fil integritet OK!"
            echo "📊 Filen er ikke ændret siden hash blev oprettet"
            
            # Vis tidsstempel for hash-fil
            echo ""
            echo "Hash-fil oprettet: $(stat -c %y "$hash_filepath")"
            echo "Original fil sidst ændret: $(stat -c %y "$original_file")"
        else
            echo "🚨 ADVARSEL: INTEGRITETSFEJL!"
            echo "❌ Filen er blevet ændret eller beskadiget!"
            echo ""
            echo "Forventet: $stored_hash"
            echo "Faktisk:   $current_hash"
            echo ""
            echo "🔍 Mulige årsager:"
            echo "- Filen er blevet redigeret"
            echo "- Filen er beskadiget"
            echo "- Filen er blevet erstattet"
            echo "- Hash-filen er forkert"
        fi
        
        ;;
        
    3)
        echo ""
        echo "=== BATCH PROCES ==="
        echo "Indtast mappe-sti:"
        read directory
        
        # Tjek om mappen findes
        if [ ! -d "$directory" ]; then
            echo "❌ FEJL: Mappen '$directory' findes ikke!"
            exit 1
        fi
        
        echo ""
        echo "🔍 Søger efter filer i: $directory"
        echo "=================================="
        
        # Find alle filer (ikke mapper)
        find "$directory" -type f | while read file; do
            echo ""
            echo "Processer: $(basename "$file")"
            
            # Generer hash
            hash_output=$(sha256sum "$file")
            hash_file="${file}.sha256"
            echo "$hash_output" > "$hash_file"
            
            echo "✅ Hash oprettet: $hash_file"
        done
        
        echo ""
        echo "📊 Batch proces afsluttet"
        echo "Hash-filer oprettet for alle filer i mappen"
        
        ;;
        
    *)
        echo "❌ Ugyldigt valg!"
        exit 1
        ;;
esac

echo ""
echo "🔐 Hash Information:"
echo "==================="
echo "SHA256 er en kryptografisk hash-funktion"
echo "- 256-bit (64 tegn) hexadecimal output"
echo "- Kollisionssikker (praktisk umulig at finde to filer med samme hash)"
echo "- Énvejsfunktion (umulig at genskabe fil fra hash)"
echo "- Deterministisk (samme fil = samme hash altid)"

echo ""
echo "💡 Anvendelser:"
echo "=============="
echo "- Fil integritetsjek"
echo "- Verificere downloads"
echo "- Forensik og bevissikring"
echo "- Backup verifikation"
echo "- Malware detektion"

echo ""
echo "Script afsluttet: $(date)"

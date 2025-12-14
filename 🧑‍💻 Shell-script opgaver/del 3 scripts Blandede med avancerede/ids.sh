#!/bin/bash

# Super Simpel IDS
# Brug: ./ids.sh init /mappe    ELLER    ./ids.sh check /mappe

DB="$HOME/checksums.txt"

if [ "$1" == "init" ]; then
    DIR="$2"
    if [ -z "$DIR" ]; then
        echo "Brug: $0 init /mappe"
        exit 1
    fi
    
    echo "Opretter baseline for $DIR ..."
    find "$DIR" -type f 2>/dev/null | while read file; do
        hash=$(sha256sum "$file" 2>/dev/null | cut -d' ' -f1)
        echo "$file|$hash" >> "$DB"
    done
    echo "Færdig! Baseline gemt i $DB"

elif [ "$1" == "check" ]; then
    DIR="$2"
    if [ -z "$DIR" ]; then
        echo "Brug: $0 check /mappe"
        exit 1
    fi
    
    if [ ! -f "$DB" ]; then
        echo "Ingen baseline! Kør først: $0 init $DIR"
        exit 1
    fi
    
    echo "Tjekker $DIR ..."
    find "$DIR" -type f 2>/dev/null | while read file; do
        new_hash=$(sha256sum "$file" 2>/dev/null | cut -d' ' -f1)
        old_hash=$(grep "^$file|" "$DB" | cut -d'|' -f2)
        
        if [ -z "$old_hash" ]; then
            echo "[NY] $file"
        elif [ "$new_hash" != "$old_hash" ]; then
            echo "[ÆNDRET] $file"
        fi
    done
    echo "Færdig!"

else
    echo "Brug:"
    echo "  $0 init /mappe     - Opret baseline"
    echo "  $0 check /mappe    - Tjek ændringer"
    echo ""
    echo "Eksempel:"
    echo "  $0 init ~/Documents"
    echo "  $0 check ~/Documents"
fi

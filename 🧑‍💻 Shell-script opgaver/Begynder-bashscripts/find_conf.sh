#!/bin/bash

# Script til at finde alle .conf filer i /etc
# Forfatter: [Dit navn]
# Dato: $(date +%Y-%m-%d)

echo "Søger efter .conf filer i /etc mappen..."
echo "=========================================="

# Find alle filer der ender på .conf i /etc
ls /etc/*.conf 2>/dev/null

echo ""
echo "Med detaljeret information:"
echo "=========================="

# Vis med detaljeret information (størrelse, tilladelser, dato)
ls -lh /etc/*.conf 2>/dev/null

echo ""
echo "Antal .conf filer fundet:"
ls /etc/*.conf 2>/dev/null | wc -l

echo ""
echo "Søgning fuldført: $(date)"

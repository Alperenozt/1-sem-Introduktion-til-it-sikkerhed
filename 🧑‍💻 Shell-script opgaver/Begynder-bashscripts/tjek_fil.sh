#!/bin/bash

# Script til at tjekke om en fil findes
# Forfatter: [Dit navn]
# Dato: $(date +%Y-%m-%d)

echo "Fil-tjekker script"
echo "=================="

# Bed brugeren om at indtaste et filnavn
echo "Indtast filnavn (med fuld sti):"
read filnavn

echo ""
echo "Tjekker om filen '$filnavn' findes..."
echo ""

# Tjek om filen findes
if [ -f "$filnavn" ]; then
    echo "✅ SUCCES: Filen '$filnavn' findes!"
    echo ""
    echo "Fil information:"
    ls -lh "$filnavn"
    echo ""
    echo "Filtype:"
    file "$filnavn"
else
    echo "❌ FEJL: Filen '$filnavn' findes IKKE!"
    echo ""
    echo "Tjek at:"
    echo "- Filnavnet er stavet rigtigt"
    echo "- Du har angivet den fulde sti"
    echo "- Du har læserettigheder til mappen"
fi

echo ""
echo "Tjek afsluttet: $(date)"

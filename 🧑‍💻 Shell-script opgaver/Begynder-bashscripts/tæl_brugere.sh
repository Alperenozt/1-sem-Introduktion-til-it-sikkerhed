#!/bin/bash

# Script til at tælle indloggede brugere
# Forfatter: [Dit navn]
# Dato: $(date +%Y-%m-%d)

echo "Brugertæller Script"
echo "==================="

echo "Alle aktive sessioner:"
echo "----------------------"
who

echo ""
echo "Detaljeret oversigt:"
echo "-------------------"
w

echo ""
echo "Sammendrag:"
echo "----------"

# Tæl antallet af indloggede brugere
antal_brugere=$(who | wc -l)
echo "📊 Antal aktive sessioner: $antal_brugere"

# Tæl unikke brugere (hvis samme bruger er logget ind flere steder)
unikke_brugere=$(who | awk '{print $1}' | sort | uniq | wc -l)
echo "👤 Antal unikke brugere: $unikke_brugere"

echo ""
echo "Unikke brugere logget ind:"
who | awk '{print $1}' | sort | uniq

echo ""
echo "Tjek udført: $(date)"

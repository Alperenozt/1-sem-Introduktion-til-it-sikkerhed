#!/bin/bash

# Script til at vise processer for en bestemt bruger
# Forfatter: [Dit navn]
# Dato: $(date +%Y-%m-%d)

echo "Proces-søger Script"
echo "==================="

# Bed brugeren om at indtaste brugernavn
echo "Indtast brugernavn (eller tryk Enter for nuværende bruger):"
read brugernavn

# Hvis ingen input, brug nuværende bruger
if [ -z "$brugernavn" ]; then
    brugernavn=$(whoami)
    echo "Bruger nuværende bruger: $brugernavn"
fi

echo ""
echo "Søger efter processer for bruger: '$brugernavn'"
echo "================================================"

# Tjek om brugeren findes i systemet
if ! id "$brugernavn" &>/dev/null; then
    echo "❌ FEJL: Brugeren '$brugernavn' findes ikke i systemet!"
    echo ""
    echo "Tilgængelige brugere:"
    cut -d: -f1 /etc/passwd | sort
    exit 1
fi

echo ""
echo "Detaljerede processer:"
echo "---------------------"
ps aux | grep "^$brugernavn" | grep -v grep

echo ""
echo "Sammendrag:"
echo "----------"

# Tæl antallet af processer
antal_processer=$(ps aux | grep "^$brugernavn" | grep -v grep | wc -l)
echo "📊 Antal processer for '$brugernavn': $antal_processer"

# Vis CPU og hukommelsesforbrug
echo ""
echo "Ressourceforbrug:"
echo "----------------"
ps aux | grep "^$brugernavn" | grep -v grep | awk '{cpu+=$3; mem+=$4} END {printf "🖥️  Total CPU: %.1f%%\n💾 Total Hukommelse: %.1f%%\n", cpu, mem}'

echo ""
echo "Top 5 processer (efter CPU forbrug):"
echo "------------------------------------"
ps aux | grep "^$brugernavn" | grep -v grep | sort -k3 -nr | head -5 | awk '{printf "%-20s %6s%% CPU %6s%% MEM %s\n", $11, $3, $4, $2}'

echo ""
echo "Søgning afsluttet: $(date)"

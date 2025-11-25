#!/bin/bash

# Script til at vise mislykkede loginforsøg (Kali/systemd version)
# Forfatter: [Dit navn]
# Dato: $(date +%Y-%m-%d)

echo "Mislykkede Login Overvågning (Kali Linux)"
echo "=========================================="

# Tjek om journalctl findes
if ! command -v journalctl &> /dev/null; then
    echo "❌ FEJL: journalctl ikke fundet!"
    exit 1
fi

echo "Analyserer systemd journal..."
echo "Søger efter mislykkede loginforsøg..."
echo ""

# Find mislykkede SSH forsøg
echo "🔍 SSH Mislykkede forsøg (sidste 10):"
echo "======================================"
ssh_attempts=$(sudo journalctl | grep -i "failed password.*ssh" | tail -10)

if [ -n "$ssh_attempts" ]; then
    echo "$ssh_attempts" | while read line; do
        # Udtræk dato og tid (første 3 felter)
        date_time=$(echo "$line" | awk '{print $1, $2, $3}')
        echo "⏰ $date_time"
        echo "📝 $line"
        echo ""
    done
else
    echo "✅ Ingen SSH mislykkede forsøg fundet"
fi

echo ""

# Find mislykkede sudo forsøg
echo "🔍 SUDO Mislykkede forsøg (sidste 10):"
echo "======================================"
sudo_attempts=$(sudo journalctl | grep -i "authentication failure.*sudo" | tail -10)

if [ -n "$sudo_attempts" ]; then
    echo "$sudo_attempts" | while read line; do
        date_time=$(echo "$line" | awk '{print $1, $2, $3}')
        user=$(echo "$line" | grep -o "user=[a-zA-Z0-9_-]*" | cut -d'=' -f2)
        echo "⏰ $date_time"
        echo "👤 Bruger: $user"
        echo "📝 $line"
        echo ""
    done
else
    echo "✅ Ingen sudo mislykkede forsøg fundet"
fi

# Find andre authentication failures
echo "🔍 Andre authentication fejl (sidste 10):"
echo "=========================================="
other_failures=$(sudo journalctl | grep -i "authentication failure" | grep -v "sudo" | tail -10)

if [ -n "$other_failures" ]; then
    echo "$other_failures" | while read line; do
        date_time=$(echo "$line" | awk '{print $1, $2, $3}')
        echo "⏰ $date_time"
        echo "📝 $line"
        echo ""
    done
else
    echo "✅ Ingen andre authentication fejl fundet"
fi

# Sammendrag statistik
echo "📊 Statistik oversigt (hele journal):"
echo "====================================="

# Tæl SSH fejl
ssh_failures=$(sudo journalctl | grep -c "failed password.*ssh" 2>/dev/null || echo "0")
echo "🔐 SSH fejl total: $ssh_failures"

# Tæl sudo fejl
sudo_failures=$(sudo journalctl | grep -c "authentication failure.*sudo" 2>/dev/null || echo "0")
echo "🔒 Sudo fejl total: $sudo_failures"

# Tæl andre auth fejl
other_failures=$(sudo journalctl | grep -c "authentication failure" | grep -v "sudo" 2>/dev/null || echo "0")
echo "🚫 Andre auth fejl: $other_failures"

# Vis seneste aktivitet (i dag)
echo ""
echo "📅 Aktivitet i dag:"
echo "=================="
today_activity=$(sudo journalctl --since today | grep -i "authentication failure\|failed password")

if [ -n "$today_activity" ]; then
    echo "$today_activity"
else
    echo "✅ Ingen mislykkede forsøg i dag"
fi

echo ""
echo "Analyse afsluttet: $(date)"
echo ""
echo "💡 Tips for Kali Linux:"
echo "- Brug 'sudo journalctl -f' til real-time overvågning"
echo "- Tjek 'sudo journalctl --since yesterday' for gårsdagens aktivitet"
echo "- Overvej at aktivere SSH hvis du vil teste SSH fejl"
echo "- Installer fail2ban: sudo apt install fail2ban"

#!/bin/bash

# Script til overvågning af ændringer i /etc/passwd
# Forfatter: [Dit navn]
# Dato: $(date +%Y-%m-%d)

echo "Passwd Fil Overvågning"
echo "======================"

# Filsti og backup lokationer
PASSWD_FILE="/etc/passwd"
BACKUP_DIR="$HOME/passwd_backups"
BACKUP_FILE="$BACKUP_DIR/passwd_backup_$(date +%Y%m%d_%H%M%S)"
LAST_BACKUP="$BACKUP_DIR/passwd_last_backup"
LOG_FILE="$HOME/passwd_changes.log"

# Opret backup mappe hvis den ikke findes
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
    echo "📁 Oprettet backup mappe: $BACKUP_DIR"
fi

echo "Overvåger: $PASSWD_FILE"
echo "Backup mappe: $BACKUP_DIR"
echo "Log fil: $LOG_FILE"
echo ""

# Tjek om passwd filen findes og er læsbar
if [ ! -f "$PASSWD_FILE" ]; then
    echo "❌ FEJL: $PASSWD_FILE ikke fundet!"
    exit 1
fi

if [ ! -r "$PASSWD_FILE" ]; then
    echo "❌ FEJL: Ingen læserettigheder til $PASSWD_FILE"
    echo "Kør med: sudo $0"
    exit 1
fi

# Vis nuværende status
echo "📊 Nuværende passwd fil info:"
echo "============================="
ls -lh "$PASSWD_FILE"
echo "Antal brugere: $(wc -l < "$PASSWD_FILE")"

# Opret backup af nuværende tilstand
echo ""
echo "💾 Opretter backup..."
cp "$PASSWD_FILE" "$BACKUP_FILE"
echo "Backup gemt som: $BACKUP_FILE"

# Hvis der er en tidligere backup, sammenlign
if [ -f "$LAST_BACKUP" ]; then
    echo ""
    echo "🔍 Sammenligner med sidste backup..."
    echo "==================================="
    
    # Brug diff til at finde forskelle
    if diff -q "$LAST_BACKUP" "$PASSWD_FILE" > /dev/null; then
        echo "✅ Ingen ændringer siden sidste tjek"
        echo "$(date): Ingen ændringer i $PASSWD_FILE" >> "$LOG_FILE"
    else
        echo "🚨 ÆNDRINGER DETEKTERET!"
        echo ""
        
        # Log ændringen
        echo "$(date): ÆNDRINGER DETEKTERET i $PASSWD_FILE" >> "$LOG_FILE"
        
        # Vis detaljerede forskelle
        echo "📋 Detaljerede forskelle:"
        echo "========================"
        
        # Viser side-by-side sammenligning
        echo "FØR (venstre) vs NU (højre):"
        echo "----------------------------"
        diff --side-by-side --width=120 "$LAST_BACKUP" "$PASSWD_FILE" || true
        
        echo ""
        echo "📝 Kun ændrede linjer:"
        echo "====================="
        
        # Viser kun nye/ændrede linjer
        echo "TILFØJEDE LINJER (+):"
        diff "$LAST_BACKUP" "$PASSWD_FILE" | grep "^>" | sed 's/^> //' || echo "Ingen tilføjede linjer"
        
        echo ""
        echo "FJERNEDE LINJER (-):"
        diff "$LAST_BACKUP" "$PASSWD_FILE" | grep "^<" | sed 's/^< //' || echo "Ingen fjernede linjer"
        
        # Gem detaljeret diff til log
        echo "" >> "$LOG_FILE"
        echo "=== DETALJERET DIFF $(date) ===" >> "$LOG_FILE"
        diff "$LAST_BACKUP" "$PASSWD_FILE" >> "$LOG_FILE" 2>/dev/null || true
        echo "=== SLUT DIFF ===" >> "$LOG_FILE"
        echo "" >> "$LOG_FILE"
        
        echo ""
        echo "🔔 Mulige ændringer at undersøge:"
        echo "- Nye brugere tilføjet"
        echo "- Brugere slettet"
        echo "- Bruger ID (UID) ændret"
        echo "- Hjemmemappe ændret"
        echo "- Shell ændret"
        echo "- Gruppe ID (GID) ændret"
    fi
else
    echo ""
    echo "ℹ️  Første kørsel - intet at sammenligne med"
    echo "$(date): Første overvågning af $PASSWD_FILE" >> "$LOG_FILE"
fi

# Gem nuværende backup som reference til næste gang
cp "$PASSWD_FILE" "$LAST_BACKUP"

echo ""
echo "📈 Backup historik:"
echo "=================="
ls -lht "$BACKUP_DIR" | head -6

echo ""
echo "📜 Log fil statistik:"
echo "===================="
if [ -f "$LOG_FILE" ]; then
    echo "Log størrelse: $(du -h "$LOG_FILE" | cut -f1)"
    echo "Antal log entries: $(grep -c "$(date +%Y)" "$LOG_FILE" 2>/dev/null || echo 0) i år"
    echo ""
    echo "Seneste 5 log entries:"
    tail -5 "$LOG_FILE" 2>/dev/null || echo "Ingen log entries endnu"
else
    echo "Log fil endnu ikke oprettet"
fi

echo ""
echo "✅ Overvågning afsluttet: $(date)"
echo ""
echo "💡 Tips:"
echo "- Kør dette script regelmæssigt (f.eks. via cron)"
echo "- Tjek log filen for historik: cat $LOG_FILE"
echo "- Undersøg uventede ændringer grundigt"

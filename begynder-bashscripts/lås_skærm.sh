#!/bin/bash

# Script til automatisk skærmlås efter inaktivitet (uden extra installation)
# Forfatter: [Dit navn]
# Dato: $(date +%Y-%m-%d)

echo "Simpel Automatisk Skærmlås"
echo "=========================="

# Inaktivitetstid i sekunder (5 minutter = 300 sekunder)
TIMEOUT=300
echo "Venter $((TIMEOUT/60)) minutter før skærmlås"

# Find tilgængelig lås-kommando (uden installation)
get_lock_command() {
    # Prøv systemd (fungerer på de fleste moderne Linux)
    if command -v loginctl &> /dev/null; then
        echo "loginctl lock-session"
    # Prøv GNOME (ofte allerede installeret)
    elif command -v gdbus &> /dev/null; then
        echo "gdbus call --session --dest=org.gnome.ScreenSaver --object-path=/org/gnome/ScreenSaver --method=org.gnome.ScreenSaver.Lock"
    # Prøv dbus generisk
    elif command -v dbus-send &> /dev/null; then
        echo "dbus-send --session --dest=org.gnome.ScreenSaver --type=method_call /org/gnome/ScreenSaver org.gnome.ScreenSaver.Lock"
    # Backup: prøv xset (screensaver aktivering)
    elif command -v xset &> /dev/null; then
        echo "xset dpms force off"
    else
        echo ""
    fi
}

LOCK_CMD=$(get_lock_command)

if [ -z "$LOCK_CMD" ]; then
    echo "❌ FEJL: Ingen lås-kommando fundet!"
    echo "Prøv at køre manuelt: loginctl lock-session"
    exit 1
fi

echo "Bruger: $LOCK_CMD"
echo ""
echo "Starter nedtælling..."
echo "Tryk Ctrl+C for at stoppe"
echo "========================"

# Simpel timer uden at måle faktisk inaktivitet
countdown=$TIMEOUT

while [ $countdown -gt 0 ]; do
    minutes=$((countdown / 60))
    seconds=$((countdown % 60))
    
    printf "\rLåser om: %02d:%02d" $minutes $seconds
    
    sleep 1
    countdown=$((countdown - 1))
done

echo ""
echo "$(date): Timer udløbet - låser skærm!"
eval $LOCK_CMD

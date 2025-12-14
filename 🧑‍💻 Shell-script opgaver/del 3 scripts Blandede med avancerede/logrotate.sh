#!/bin/bash

# Simpel Log Rotator
# Brug: ./simple_log_rotate.sh

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Config
ARCHIVE_DIR="$HOME/log_archive"
KEY_FILE="$HOME/.logkey"

# Logs at rotere
LOGS=(
    "/var/log/auth.log"
    "/var/log/syslog"
    "$HOME/.bash_history"
)

mkdir -p "$ARCHIVE_DIR"

# Generer krypteringsnøgle hvis den ikke findes
if [ ! -f "$KEY_FILE" ]; then
    echo "MitSuperHemmeligePassword123" > "$KEY_FILE"
    chmod 600 "$KEY_FILE"
    echo -e "${GREEN}✓ Krypteringsnøgle oprettet${NC}"
fi

KEY=$(cat "$KEY_FILE")

# Roter én log
rotate_log() {
    local logfile="$1"
    
    if [ ! -f "$logfile" ]; then
        echo -e "${YELLOW}Springer over: $logfile${NC}"
        return
    fi
    
    local name=$(basename "$logfile")
    local date=$(date +%Y%m%d_%H%M%S)
    local output="$ARCHIVE_DIR/${name}_${date}.log.enc"
    
    echo -e "${GREEN}Roterer: $name${NC}"
    
    # Kopier, krypter, nulstil
    if [ -r "$logfile" ]; then
        cat "$logfile" | gzip | openssl enc -aes-256-cbc -salt -k "$KEY" -out "$output"
        > "$logfile"
    else
        sudo cat "$logfile" | gzip | openssl enc -aes-256-cbc -salt -k "$KEY" -out "$output"
        sudo truncate -s 0 "$logfile"
    fi
}

# Dekrypter log
decrypt_log() {
    local file="$1"
    
    if [ -z "$file" ]; then
        echo "Arkiverede logs:"
        ls -lh "$ARCHIVE_DIR"/*.enc 2>/dev/null | awk '{print $9, $5}'
        echo ""
        echo "Brug: $0 decrypt filnavn.enc"
        return
    fi
    
    openssl enc -d -aes-256-cbc -k "$KEY" -in "$ARCHIVE_DIR/$file" | gunzip | less
}

# Main
case "$1" in
    rotate)
        echo -e "${YELLOW}Roterer logs...${NC}"
        for log in "${LOGS[@]}"; do
            rotate_log "$log"
        done
        echo -e "${GREEN}✓ Færdig!${NC}"
        ;;
    
    decrypt)
        decrypt_log "$2"
        ;;
    
    list)
        echo "Arkiverede logs:"
        ls -lh "$ARCHIVE_DIR"/*.enc 2>/dev/null | awk '{print $9, $5}' || echo "Ingen logs endnu"
        ;;
    
    *)
        echo "Brug:"
        echo "  $0 rotate          - Roter logs nu"
        echo "  $0 list            - Vis arkiver"
        echo "  $0 decrypt <fil>   - Vis log"
        echo ""
        echo "Setup cron (automatisk hver nat kl. 2):"
        echo "  (crontab -l; echo '0 2 * * * $PWD/$0 rotate') | crontab -"
        ;;
esac

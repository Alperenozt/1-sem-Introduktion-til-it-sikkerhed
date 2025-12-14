#!/bin/bash

# Shadow File Monitor - Overvåger /etc/shadow rettigheder
# Brug: ./shadow_monitor.sh [start|check|stop]

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SHADOW_FILE="/etc/shadow"
STATE_FILE="$HOME/.shadow_monitor_state"
LOG_FILE="$HOME/.shadow_monitor.log"
PID_FILE="$HOME/.shadow_monitor.pid"

# Tjek om vi kører som root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Dette script skal køres som root!${NC}"
    echo "Brug: sudo $0"
    exit 1
fi

# Gem nuværende tilstand
save_state() {
    local perms=$(stat -c%a "$SHADOW_FILE")
    local owner=$(stat -c%U:%G "$SHADOW_FILE")
    local hash=$(sha256sum "$SHADOW_FILE" | cut -d' ' -f1)
    
    echo "$perms|$owner|$hash" > "$STATE_FILE"
}

# Tjek for ændringer
check_changes() {
    if [ ! -f "$STATE_FILE" ]; then
        echo -e "${YELLOW}Første check - opretter baseline${NC}"
        save_state
        return 0
    fi
    
    # Læs gammel tilstand
    IFS='|' read -r old_perms old_owner old_hash < "$STATE_FILE"
    
    # Hent nuværende tilstand
    local new_perms=$(stat -c%a "$SHADOW_FILE")
    local new_owner=$(stat -c%U:%G "$SHADOW_FILE")
    local new_hash=$(sha256sum "$SHADOW_FILE" | cut -d' ' -f1)
    
    local changes=0
    
    # Tjek rettigheder
    if [ "$old_perms" != "$new_perms" ]; then
        echo -e "${RED}⚠ ADVARSEL: Rettigheder ændret!${NC}"
        echo "  Før:  $old_perms"
        echo "  Nu:   $new_perms"
        echo "[$(date)] PERMISSIONS CHANGED: $old_perms -> $new_perms" >> "$LOG_FILE"
        changes=1
    fi
    
    # Tjek ejer
    if [ "$old_owner" != "$new_owner" ]; then
        echo -e "${RED}⚠ ADVARSEL: Ejer ændret!${NC}"
        echo "  Før:  $old_owner"
        echo "  Nu:   $new_owner"
        echo "[$(date)] OWNER CHANGED: $old_owner -> $new_owner" >> "$LOG_FILE"
        changes=1
    fi
    
    # Tjek filindhold
    if [ "$old_hash" != "$new_hash" ]; then
        echo -e "${YELLOW}ℹ INFO: Filindhold ændret${NC}"
        echo "  (Dette er normalt hvis passwords er blevet ændret)"
        echo "[$(date)] CONTENT CHANGED" >> "$LOG_FILE"
    fi
    
    if [ $changes -eq 0 ]; then
        echo -e "${GREEN}✓ Ingen mistænkelige ændringer${NC}"
    else
        # Send alert
        echo -e "${RED}═══════════════════════════════════════${NC}"
        echo -e "${RED}  SIKKERHEDSADVARSEL - /etc/shadow    ${NC}"
        echo -e "${RED}═══════════════════════════════════════${NC}"
    fi
    
    # Opdater state
    save_state
    
    return $changes
}

# Start daemon
start_daemon() {
    if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
        echo -e "${YELLOW}Monitor kører allerede (PID: $(cat $PID_FILE))${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}Starter shadow monitor...${NC}"
    
    # Opret initial baseline
    save_state
    
    # Start baggrundprocess
    (
        while true; do
            check_changes
            sleep 60
        done
    ) &
    
    echo $! > "$PID_FILE"
    echo -e "${GREEN}✓ Monitor startet (PID: $!)${NC}"
    echo -e "${YELLOW}Stop med: sudo $0 stop${NC}"
}

# Stop daemon
stop_daemon() {
    if [ ! -f "$PID_FILE" ]; then
        echo -e "${YELLOW}Monitor kører ikke${NC}"
        exit 0
    fi
    
    local pid=$(cat "$PID_FILE")
    
    if kill -0 $pid 2>/dev/null; then
        kill $pid
        rm "$PID_FILE"
        echo -e "${GREEN}✓ Monitor stoppet${NC}"
    else
        echo -e "${YELLOW}Monitor kører ikke (stale PID)${NC}"
        rm "$PID_FILE"
    fi
}

# Status
show_status() {
    echo -e "${YELLOW}═══ Shadow Monitor Status ═══${NC}"
    echo ""
    
    if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
        echo -e "${GREEN}Status: RUNNING${NC}"
        echo "PID: $(cat $PID_FILE)"
    else
        echo -e "${RED}Status: STOPPED${NC}"
    fi
    
    echo ""
    echo -e "${YELLOW}═══ Nuværende /etc/shadow ═══${NC}"
    echo "Rettigheder: $(stat -c%a $SHADOW_FILE)"
    echo "Ejer:        $(stat -c%U:%G $SHADOW_FILE)"
    echo "Sidst ændret: $(stat -c%y $SHADOW_FILE)"
    
    if [ -f "$LOG_FILE" ]; then
        echo ""
        echo -e "${YELLOW}═══ Seneste alerts ═══${NC}"
        tail -5 "$LOG_FILE"
    fi
}

# Main
case "${1:-check}" in
    start)
        start_daemon
        ;;
    stop)
        stop_daemon
        ;;
    check)
        check_changes
        ;;
    status)
        show_status
        ;;
    *)
        echo "Brug: $0 {start|stop|check|status}"
        echo ""
        echo "  start  - Start kontinuerlig overvågning"
        echo "  stop   - Stop overvågning"
        echo "  check  - Én gang check"
        echo "  status - Vis status"
        exit 1
        ;;
esac

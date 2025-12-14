#!/bin/bash

# Process Monitor - Dræber processer der matcher et nøgleord
# Brug: ./process_monitor.sh <nøgleord> [interval_sekunder]

# Farver til output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Tjek om nøgleord er givet
if [ $# -eq 0 ]; then
    echo -e "${RED}Fejl: Mangler nøgleord${NC}"
    echo "Brug: $0 <nøgleord> [interval_sekunder]"
    echo "Eksempel: $0 firefox 5"
    exit 1
fi

KEYWORD=$1
INTERVAL=${2:-10}  # Standard interval er 10 sekunder hvis ikke angivet

echo -e "${GREEN}=== Process Monitor ===${NC}"
echo -e "Overvåger processer med nøgleord: ${YELLOW}$KEYWORD${NC}"
echo -e "Interval: ${YELLOW}$INTERVAL${NC} sekunder"
echo -e "Tryk Ctrl+C for at stoppe\n"

# Log fil
LOGFILE="process_monitor_$(date +%Y%m%d_%H%M%S).log"
echo "Process Monitor startet: $(date)" > "$LOGFILE"
echo "Nøgleord: $KEYWORD" >> "$LOGFILE"
echo "---" >> "$LOGFILE"

# Tæller for dræbte processer
KILLED_COUNT=0

# Funktion til at dræbe matchende processer
kill_matching_processes() {
    # Find processer der matcher nøgleordet (undtagen dette script selv)
    PIDS=$(ps aux | grep -i "$KEYWORD" | grep -v grep | grep -v "$0" | awk '{print $2}')
    
    if [ -z "$PIDS" ]; then
        echo -e "[$(date +%H:%M:%S)] ${GREEN}Ingen matchende processer fundet${NC}"
        return
    fi
    
    # Dræb hver proces
    for PID in $PIDS; do
        # Hent process info
        PROCESS_INFO=$(ps -p $PID -o pid,user,%cpu,%mem,cmd --no-headers 2>/dev/null)
        
        if [ -n "$PROCESS_INFO" ]; then
            echo -e "[$(date +%H:%M:%S)] ${RED}Dræber proces:${NC} PID=$PID"
            echo "  $PROCESS_INFO"
            
            # Log til fil
            echo "[$(date)] DRÆBT: $PROCESS_INFO" >> "$LOGFILE"
            
            # Forsøg SIGTERM først (pæn afslutning)
            kill -15 $PID 2>/dev/null
            sleep 1
            
            # Tjek om processen stadig kører
            if ps -p $PID > /dev/null 2>&1; then
                echo -e "  ${YELLOW}Proces svarer ikke, bruger SIGKILL...${NC}"
                kill -9 $PID 2>/dev/null
            fi
            
            KILLED_COUNT=$((KILLED_COUNT + 1))
        fi
    done
}

# Trap Ctrl+C for pæn afslutning
trap 'echo -e "\n${GREEN}Monitor stoppet. Total dræbte processer: $KILLED_COUNT${NC}"; echo "Monitor stoppet: $(date)" >> "$LOGFILE"; echo "Total dræbte processer: $KILLED_COUNT" >> "$LOGFILE"; exit 0' INT

# Hovedloop
while true; do
    kill_matching_processes
    sleep $INTERVAL
done

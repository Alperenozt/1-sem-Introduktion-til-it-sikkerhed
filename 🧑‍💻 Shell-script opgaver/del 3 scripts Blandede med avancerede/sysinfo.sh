#!/bin/bash

# System Info - Vis hostname og IP
# Brug: ./sysinfo.sh

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}═══════════════════════════════${NC}"
echo -e "${GREEN}    System Information         ${NC}"
echo -e "${GREEN}═══════════════════════════════${NC}"
echo ""

# Hostname
echo -e "${CYAN}Hostname:${NC}"
echo "  $(hostname)"
echo ""

# Local IP (alle interfaces)
echo -e "${CYAN}Local IP:${NC}"
ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v 127.0.0.1 | while read ip; do
    interface=$(ip -4 addr show | grep "$ip" | awk '{print $NF}')
    echo "  $ip ($interface)"
done
echo ""

# Public IP
echo -e "${CYAN}Public IP:${NC}"
public_ip=$(curl -s ifconfig.me 2>/dev/null || curl -s icanhazip.com 2>/dev/null || echo "N/A")
echo "  $public_ip"
echo ""

# Gateway
echo -e "${CYAN}Gateway:${NC}"
gateway=$(ip route | grep default | awk '{print $3}')
echo "  ${gateway:-N/A}"
echo ""

# MAC addresses
echo -e "${CYAN}MAC Addresses:${NC}"
ip link show | grep -E "link/ether" | while read line; do
    mac=$(echo "$line" | awk '{print $2}')
    interface=$(ip link show | grep -B1 "$mac" | head -1 | awk -F: '{print $2}' | xargs)
    echo "  $interface: $mac"
done
echo ""

echo -e "${GREEN}═══════════════════════════════${NC}"

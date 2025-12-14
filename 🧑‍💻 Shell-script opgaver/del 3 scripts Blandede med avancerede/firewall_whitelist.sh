#!/bin/bash

# Firewall Rule Generator - Genererer iptables regler fra IP whitelist
# Brug: ./firewall_whitelist.sh [whitelist_fil]

# Farver til output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Standard whitelist fil
WHITELIST_FILE=${1:-"ip_whitelist.txt"}

echo -e "${GREEN}=== Firewall Whitelist Generator ===${NC}\n"

# Tjek om script køres som root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Dette script skal køres som root!${NC}"
    echo "Brug: sudo $0 [whitelist_fil]"
    exit 1
fi

# Tjek om whitelist fil eksisterer
if [ ! -f "$WHITELIST_FILE" ]; then
    echo -e "${YELLOW}Whitelist fil ikke fundet. Opretter eksempel fil: $WHITELIST_FILE${NC}\n"
    
    cat > "$WHITELIST_FILE" << 'EOF'
# IP Whitelist - En IP per linje
# Kommentarer starter med #
# Understøtter både enkeltstående IP'er og CIDR notation

# Lokale netværk
192.168.1.0/24
10.0.0.0/8

# Specifikke IP'er
8.8.8.8
1.1.1.1

# Trusted servers
# 203.0.113.45
# 198.51.100.0/24
EOF
    
    echo -e "${GREEN}Eksempel whitelist oprettet: $WHITELIST_FILE${NC}"
    echo "Rediger filen og kør scriptet igen."
    exit 0
fi

echo -e "Læser whitelist fra: ${BLUE}$WHITELIST_FILE${NC}\n"

# Array til at gemme IP'er
declare -a WHITELIST_IPS

# Læs whitelist fil
while IFS= read -r line || [ -n "$line" ]; do
    # Fjern whitespace
    line=$(echo "$line" | xargs)
    
    # Spring over tomme linjer og kommentarer
    if [ -z "$line" ] || [[ "$line" =~ ^# ]]; then
        continue
    fi
    
    # Valider IP format (basic check)
    if [[ "$line" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(/[0-9]+)?$ ]]; then
        WHITELIST_IPS+=("$line")
        echo -e "  ${GREEN}✓${NC} $line"
    else
        echo -e "  ${RED}✗${NC} Ugyldig IP: $line (springer over)"
    fi
done < "$WHITELIST_FILE"

if [ ${#WHITELIST_IPS[@]} -eq 0 ]; then
    echo -e "\n${RED}Ingen gyldige IP'er fundet i whitelist!${NC}"
    exit 1
fi

echo -e "\n${GREEN}Fandt ${#WHITELIST_IPS[@]} gyldige IP-adresser${NC}\n"

# Menu for firewall konfiguration
echo -e "${YELLOW}Vælg firewall konfiguration:${NC}"
echo "1) Strict Mode - Blokér ALT undtagen whitelist (anbefalet)"
echo "2) SSH Only - Tillad kun SSH fra whitelist"
echo "3) Web Server - Tillad HTTP/HTTPS fra alle, SSH kun fra whitelist"
echo "4) Custom Ports - Angiv specifikke porte"
echo "5) Vis regler uden at anvende"
echo "6) Nulstil firewall (flush alle regler)"
read -p "Valg [1-6]: " CHOICE

# Funktion til at oprette backup af nuværende regler
backup_rules() {
    BACKUP_FILE="iptables_backup_$(date +%Y%m%d_%H%M%S).rules"
    iptables-save > "$BACKUP_FILE"
    echo -e "${GREEN}Backup af nuværende regler gemt: $BACKUP_FILE${NC}\n"
}

# Funktion til at nulstille firewall
flush_firewall() {
    echo -e "${YELLOW}Nulstiller firewall...${NC}"
    iptables -F
    iptables -X
    iptables -t nat -F
    iptables -t nat -X
    iptables -t mangle -F
    iptables -t mangle -X
    iptables -P INPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -P OUTPUT ACCEPT
    echo -e "${GREEN}Firewall nulstillet!${NC}"
}

# Funktion til at anvende basic regler
apply_basic_rules() {
    # Tillad loopback
    iptables -A INPUT -i lo -j ACCEPT
    iptables -A OUTPUT -o lo -j ACCEPT
    
    # Tillad etablerede forbindelser
    iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    
    # Tillad udgående trafik
    iptables -A OUTPUT -j ACCEPT
}

# Funktion til at tilføje whitelist regler
add_whitelist_rules() {
    local PORT=$1
    local PROTOCOL=${2:-tcp}
    
    for IP in "${WHITELIST_IPS[@]}"; do
        if [ -n "$PORT" ]; then
            iptables -A INPUT -p $PROTOCOL -s $IP --dport $PORT -j ACCEPT
            echo -e "  ${GREEN}✓${NC} Tilføjet: $IP -> Port $PORT/$PROTOCOL"
        else
            iptables -A INPUT -s $IP -j ACCEPT
            echo -e "  ${GREEN}✓${NC} Tilføjet: $IP -> ALT"
        fi
    done
}

# Log rejected packets
enable_logging() {
    iptables -A INPUT -m limit --limit 5/min -j LOG --log-prefix "iptables_denied: " --log-level 7
}

# Gem regler permanent
save_rules() {
    echo -e "\n${YELLOW}Vil du gemme reglerne permanent?${NC}"
    read -p "Reglerne vil ellers forsvinde ved genstart [y/N]: " SAVE
    
    if [[ "$SAVE" =~ ^[Yy]$ ]]; then
        if command -v netfilter-persistent &> /dev/null; then
            netfilter-persistent save
            echo -e "${GREEN}Regler gemt med netfilter-persistent${NC}"
        elif command -v iptables-save &> /dev/null; then
            iptables-save > /etc/iptables/rules.v4
            echo -e "${GREEN}Regler gemt til /etc/iptables/rules.v4${NC}"
        else
            echo -e "${RED}Kunne ikke finde metode til at gemme regler${NC}"
            echo "Installer: apt-get install iptables-persistent"
        fi
    fi
}

# Hovedlogik baseret på valg
case $CHOICE in
    1)
        echo -e "\n${YELLOW}=== Anvender STRICT MODE ===${NC}\n"
        backup_rules
        flush_firewall
        apply_basic_rules
        
        echo -e "\nTilføjer whitelist regler..."
        add_whitelist_rules
        
        # Blokér resten
        iptables -P INPUT DROP
        iptables -P FORWARD DROP
        
        enable_logging
        echo -e "\n${GREEN}✓ Strict mode aktiveret - kun whitelist tilladt!${NC}"
        ;;
        
    2)
        echo -e "\n${YELLOW}=== Anvender SSH ONLY MODE ===${NC}\n"
        backup_rules
        flush_firewall
        apply_basic_rules
        
        echo -e "\nTilføjer SSH regler for whitelist..."
        add_whitelist_rules 22 tcp
        
        # Blokér andet SSH
        iptables -A INPUT -p tcp --dport 22 -j DROP
        
        enable_logging
        echo -e "\n${GREEN}✓ SSH kun tilladt fra whitelist!${NC}"
        ;;
        
    3)
        echo -e "\n${YELLOW}=== Anvender WEB SERVER MODE ===${NC}\n"
        backup_rules
        flush_firewall
        apply_basic_rules
        
        # Tillad HTTP/HTTPS fra alle
        iptables -A INPUT -p tcp --dport 80 -j ACCEPT
        iptables -A INPUT -p tcp --dport 443 -j ACCEPT
        echo -e "${GREEN}✓ HTTP/HTTPS tilladt fra alle${NC}"
        
        echo -e "\nTilføjer SSH regler for whitelist..."
        add_whitelist_rules 22 tcp
        
        # Blokér andet SSH
        iptables -A INPUT -p tcp --dport 22 -j DROP
        
        enable_logging
        echo -e "\n${GREEN}✓ Web server mode aktiveret!${NC}"
        ;;
        
    4)
        echo -e "\n${YELLOW}=== Custom Ports Mode ===${NC}\n"
        read -p "Angiv porte (kommasepareret, fx: 22,80,443): " PORTS
        
        backup_rules
        flush_firewall
        apply_basic_rules
        
        IFS=',' read -ra PORT_ARRAY <<< "$PORTS"
        for PORT in "${PORT_ARRAY[@]}"; do
            PORT=$(echo $PORT | xargs)  # Trim whitespace
            echo -e "\nTilføjer regler for port $PORT..."
            add_whitelist_rules $PORT tcp
        done
        
        iptables -P INPUT DROP
        enable_logging
        echo -e "\n${GREEN}✓ Custom ports konfigureret!${NC}"
        ;;
        
    5)
        echo -e "\n${YELLOW}=== PREVIEW - Viser regler uden at anvende ===${NC}\n"
        echo "iptables -F"
        echo "iptables -A INPUT -i lo -j ACCEPT"
        echo "iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT"
        echo ""
        for IP in "${WHITELIST_IPS[@]}"; do
            echo "iptables -A INPUT -s $IP -j ACCEPT"
        done
        echo "iptables -P INPUT DROP"
        echo -e "\n${BLUE}Ingen regler blev anvendt (preview mode)${NC}"
        exit 0
        ;;
        
    6)
        echo -e "\n${RED}ADVARSEL: Dette vil nulstille alle firewall regler!${NC}"
        read -p "Er du sikker? [y/N]: " CONFIRM
        if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
            backup_rules
            flush_firewall
        else
            echo "Afbrudt."
        fi
        exit 0
        ;;
        
    *)
        echo -e "${RED}Ugyldigt valg!${NC}"
        exit 1
        ;;
esac

# Vis nuværende regler
echo -e "\n${BLUE}=== Aktive Firewall Regler ===${NC}\n"
iptables -L -v -n --line-numbers

# Gem regler
save_rules

echo -e "\n${GREEN}=== Færdig! ===${NC}"
echo -e "For at se regler: ${YELLOW}iptables -L -v -n${NC}"
echo -e "For at gendanne backup: ${YELLOW}iptables-restore < [backup_fil]${NC}"

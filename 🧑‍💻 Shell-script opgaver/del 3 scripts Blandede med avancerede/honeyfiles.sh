#!/bin/bash

# Honeyfiles - Falske følsomme filer til at fange angribere
# Brug: ./honeyfiles.sh [create|monitor|list|clean]

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

HONEY_DIR="$HOME/.honeyfiles"
LOG_FILE="$HONEY_DIR/access.log"
STATE_FILE="$HONEY_DIR/honeyfiles.list"

# Tjek om vi kører som root (kun for system-wide deployment)
SUDO_PREFIX=""
if [ "$EUID" -eq 0 ]; then
    SUDO_PREFIX="sudo"
fi

# Opret directories
mkdir -p "$HONEY_DIR"

# Honeyfile templates
declare -A HONEYFILE_TEMPLATES=(
    ["passwords.txt"]="passwords"
    ["credentials.txt"]="credentials"
    ["secrets.txt"]="secrets"
    ["private_keys.txt"]="keys"
    ["backup_codes.txt"]="backup"
    [".env"]="env"
    ["config.json"]="config"
    ["database.sql"]="database"
    ["id_rsa"]="ssh"
    [".aws_credentials"]="aws"
)

# Generer realistisk indhold
generate_content() {
    local type=$1
    
    case $type in
        passwords)
            cat << 'EOF'
# Production Passwords - DO NOT SHARE!
# Last updated: 2024-12-10

Admin Panel:
  URL: https://admin.example.com
  User: admin
  Pass: P@ssw0rd123!
  
Database:
  Host: db.internal.com
  User: db_admin
  Pass: MyS3cr3tP@ss
  
API Keys:
  OpenAI: sk-proj-abc123def456ghi789
  Stripe: sk_live_51Abc123Def456
  
WiFi:
  SSID: CompanyWiFi
  Password: C0mp@nyW1F1!
EOF
            ;;
        credentials)
            cat << 'EOF'
# System Credentials
# CONFIDENTIAL - Restricted Access

SSH Root Access:
  server1.example.com - root:toor123
  server2.example.com - root:r00tpass!
  
Email Accounts:
  admin@company.com - AdminPass2024!
  backup@company.com - BackupAcc3ss
  
FTP Server:
  ftp://files.internal.com
  Username: ftpadmin
  Password: Ftp@dm1n2024
EOF
            ;;
        secrets)
            cat << 'EOF'
SECRET_KEY=a1b2c3d4e5f6g7h8i9j0
JWT_SECRET=my-super-secret-jwt-key-12345
ENCRYPTION_KEY=AES256-encryption-key-abcdef
MASTER_PASSWORD=M@st3rP@ssw0rd!
RECOVERY_CODE=RECOVERY-2024-ABC-XYZ-123
EOF
            ;;
        keys)
            cat << 'EOF'
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA1234567890abcdefghijklmnopqrstuvwxyz
AAAABBBBCCCCDDDDEEEEFFFFGGGGHHHHIIIIJJJJKKKKLLLLMMMM
(Dette er ikke en rigtig nøgle - kun for demonstration)
-----END RSA PRIVATE KEY-----

API Keys:
- GitHub: ghp_1234567890abcdefghijklmnopqrstuv
- AWS Access: AKIAIOSFODNN7EXAMPLE
- AWS Secret: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
EOF
            ;;
        backup)
            cat << 'EOF'
Backup Codes - Save these in a secure location!

Recovery Codes:
1. ABC-123-XYZ-789
2. DEF-456-UVW-012
3. GHI-789-RST-345
4. JKL-012-OPQ-678

2FA Backup:
- Google: 1234 5678 9012 3456
- GitHub: abcd-efgh-ijkl-mnop
EOF
            ;;
        env)
            cat << 'EOF'
# Environment Variables
DB_HOST=localhost
DB_USER=admin
DB_PASS=SuperSecretPass123!
DB_NAME=production

API_KEY=sk-1234567890abcdefghijklmnop
API_SECRET=secret_1234567890

JWT_SECRET=jwt_super_secret_key
SESSION_SECRET=session_secret_12345

STRIPE_KEY=sk_live_abcdefghijklmnop
STRIPE_SECRET=whsec_1234567890
EOF
            ;;
        config)
            cat << 'EOF'
{
  "database": {
    "host": "db.internal.com",
    "user": "root",
    "password": "r00t_p@ssw0rd",
    "port": 3306
  },
  "api": {
    "key": "api_key_1234567890",
    "secret": "api_secret_abcdefgh"
  },
  "admin": {
    "username": "administrator",
    "password": "Admin123!@#"
  }
}
EOF
            ;;
        database)
            cat << 'EOF'
-- Database Backup
-- Date: 2024-12-10
-- CONFIDENTIAL

USE production;

INSERT INTO users (username, password, role) VALUES
('admin', '$2y$10$abcdefghijklmnopqrstuv', 'administrator'),
('backup', '$2y$10$zyxwvutsrqponmlkjihgfe', 'backup_admin');

-- Admin credentials
-- Username: admin
-- Password: SecureP@ss123

INSERT INTO api_keys (name, key) VALUES
('production', 'pk_live_1234567890abcdef'),
('development', 'pk_test_0987654321fedcba');
EOF
            ;;
        ssh)
            cat << 'EOF'
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAABlwAAAAdzc2gtcn
(Dette er ikke en rigtig SSH nøgle - kun honeypot)
-----END OPENSSH PRIVATE KEY-----
EOF
            ;;
        aws)
            cat << 'EOF'
[default]
aws_access_key_id = AKIAIOSFODNN7EXAMPLE
aws_secret_access_key = wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
region = us-east-1

[production]
aws_access_key_id = AKIAI1234567890ABCDE
aws_secret_access_key = abcdefghijklmnopqrstuvwxyz1234567890ABCD
region = eu-west-1
EOF
            ;;
    esac
}

# Opret honeyfiles
create_honeyfiles() {
    local location=${1:-$HOME}
    
    echo -e "${CYAN}Opretter honeyfiles i: $location${NC}"
    echo ""
    
    > "$STATE_FILE"
    
    for filename in "${!HONEYFILE_TEMPLATES[@]}"; do
        local filepath="$location/$filename"
        local content_type="${HONEYFILE_TEMPLATES[$filename]}"
        
        # Generer indhold
        generate_content "$content_type" > "$filepath"
        
        # Sæt fristende rettigheder
        chmod 600 "$filepath"
        
        # Gem i state
        echo "$filepath" >> "$STATE_FILE"
        
        echo -e "${GREEN}✓${NC} Oprettet: $filename"
    done
    
    echo ""
    echo -e "${YELLOW}Honeyfiles oprettet!${NC}"
    echo -e "${CYAN}Installer auditd for at logge adgang:${NC}"
    echo "  sudo apt install auditd -y"
    echo "  sudo ./honeyfiles.sh monitor"
}

# Setup monitoring med auditd
setup_monitoring() {
    # Tjek om auditd er installeret
    if ! command -v auditctl &> /dev/null; then
        echo -e "${YELLOW}Installerer auditd...${NC}"
        apt-get update -qq
        apt-get install -y auditd audispd-plugins 2>/dev/null
        systemctl start auditd
        systemctl enable auditd
    fi
    
    echo -e "${CYAN}Opsætter monitoring...${NC}"
    
    if [ ! -f "$STATE_FILE" ]; then
        echo -e "${RED}Ingen honeyfiles fundet!${NC}"
        echo "Kør først: $0 create"
        exit 1
    fi
    
    # Fjern gamle audit rules for honeyfiles
    auditctl -D 2>/dev/null | grep -i honey || true
    
    # Tilføj audit rules
    while read filepath; do
        if [ -f "$filepath" ]; then
            # Monitor read/write/execute
            auditctl -w "$filepath" -p rwxa -k honeyfile_access
            echo -e "${GREEN}✓${NC} Monitoring: $filepath"
        fi
    done < "$STATE_FILE"
    
    echo ""
    echo -e "${GREEN}Monitoring aktiveret!${NC}"
    echo -e "${CYAN}Se logs med: sudo ausearch -k honeyfile_access${NC}"
    
    # Start log watcher i baggrunden
    start_log_watcher
}

# Start log watcher
start_log_watcher() {
    local watch_script="$HONEY_DIR/watcher.sh"
    
    cat > "$watch_script" << 'WATCHEOF'
#!/bin/bash
LOG_FILE="$HOME/.honeyfiles/access.log"
echo "[$(date)] Honeyfile monitoring started" >> "$LOG_FILE"

while true; do
    # Tjek audit log
    ausearch -k honeyfile_access -ts recent 2>/dev/null | while read -r line; do
        if echo "$line" | grep -q "type=SYSCALL"; then
            timestamp=$(date)
            echo "[$timestamp] ALERT: $line" >> "$LOG_FILE"
            
            # Send desktop notification
            notify-send -u critical "🚨 HONEYFILE ACCESS!" "Suspicious activity detected!" 2>/dev/null || true
        fi
    done
    sleep 10
done
WATCHEOF
    
    chmod +x "$watch_script"
    
    # Start i baggrund hvis ikke allerede kører
    if ! pgrep -f "watcher.sh" > /dev/null; then
        nohup "$watch_script" > /dev/null 2>&1 &
        echo -e "${GREEN}✓ Log watcher startet${NC}"
    fi
}

# Vis honeyfile liste
list_honeyfiles() {
    if [ ! -f "$STATE_FILE" ]; then
        echo -e "${YELLOW}Ingen honeyfiles oprettet endnu${NC}"
        return
    fi
    
    echo -e "${CYAN}═══ Honeyfiles ═══${NC}"
    echo ""
    
    while read filepath; do
        if [ -f "$filepath" ]; then
            local perms=$(stat -c%a "$filepath")
            local size=$(stat -c%s "$filepath")
            local accessed=$(stat -c%x "$filepath" | cut -d'.' -f1)
            echo -e "${GREEN}✓${NC} $filepath"
            echo "   Rettigheder: $perms | Størrelse: $size bytes"
            echo "   Sidst tilgået: $accessed"
            echo ""
        else
            echo -e "${RED}✗${NC} $filepath (ikke fundet)"
        fi
    done < "$STATE_FILE"
}

# Vis access log
show_log() {
    if [ ! -f "$LOG_FILE" ]; then
        echo -e "${YELLOW}Ingen aktivitet logget endnu${NC}"
        return
    fi
    
    echo -e "${CYAN}═══ Seneste aktivitet ═══${NC}"
    echo ""
    tail -20 "$LOG_FILE"
    echo ""
    echo -e "${YELLOW}Se fuld log: cat $LOG_FILE${NC}"
    
    # Vis audit log hvis tilgængelig
    if command -v ausearch &> /dev/null; then
        echo ""
        echo -e "${CYAN}═══ Audit Log (honeyfiles) ═══${NC}"
        ausearch -k honeyfile_access 2>/dev/null | tail -20 || echo "Ingen audit events"
    fi
}

# Ryd op
cleanup() {
    echo -e "${YELLOW}Rydder op...${NC}"
    
    if [ -f "$STATE_FILE" ]; then
        while read filepath; do
            if [ -f "$filepath" ]; then
                rm "$filepath"
                echo -e "${GREEN}✓${NC} Slettet: $filepath"
            fi
        done < "$STATE_FILE"
    fi
    
    # Fjern audit rules
    auditctl -D 2>/dev/null | grep honeyfile || true
    
    # Stop watcher
    pkill -f "watcher.sh" 2>/dev/null || true
    
    echo -e "${GREEN}Oprydning færdig${NC}"
}

# Test honeyfile
test_honeyfile() {
    echo -e "${CYAN}Tester honeyfile system...${NC}"
    
    if [ ! -f "$STATE_FILE" ]; then
        echo -e "${RED}Ingen honeyfiles fundet!${NC}"
        exit 1
    fi
    
    # Læs første honeyfile
    local test_file=$(head -1 "$STATE_FILE")
    
    echo -e "${YELLOW}Tilgår: $test_file${NC}"
    cat "$test_file" > /dev/null
    
    sleep 2
    
    echo -e "${GREEN}✓ Test udført${NC}"
    echo -e "${CYAN}Tjek logs med: $0 log${NC}"
}

# Main
case "${1:-help}" in
    create)
        create_honeyfiles "${2:-$HOME}"
        ;;
    monitor)
        setup_monitoring
        ;;
    list)
        list_honeyfiles
        ;;
    log)
        show_log
        ;;
    test)
        test_honeyfile
        ;;
    clean)
        cleanup
        ;;
    *)
        echo -e "${GREEN}Honeyfiles - Fang angribere med falske filer${NC}"
        echo ""
        echo "Brug: $0 [kommando]"
        echo ""
        echo "Kommandoer:"
        echo "  create [mappe]  - Opret honeyfiles (default: $HOME)"
        echo "  monitor         - Setup auditd monitoring"
        echo "  list            - Vis alle honeyfiles"
        echo "  log             - Vis adgangslog"
        echo "  test            - Test systemet"
        echo "  clean           - Fjern alle honeyfiles"
        echo ""
        echo "Eksempel:"
        echo "  sudo $0 create        # Opret filer"
        echo "  sudo $0 monitor       # Start monitoring"
        echo "  $0 list               # Se liste"
        echo "  $0 log                # Se hvem der har rørt filerne"
        ;;
esac

#!/bin/bash

# Apache Log Analyzer - SQL Injection Detection
# Brug: ./apache_sqli_detector.sh [log_fil]

# Farver til output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Standard log filer
DEFAULT_LOGS=(
    "/var/log/apache2/access.log"
    "/var/log/apache2/error.log"
    "/var/log/httpd/access_log"
    "/var/log/httpd/error_log"
)

# SQL Injection patterns
declare -A SQLI_PATTERNS=(
    ["union_select"]="union.*select"
    ["sql_comment"]="(/\*|\*/|--|\#)"
    ["sql_keywords"]="(select.*from|insert.*into|delete.*from|update.*set|drop.*table)"
    ["quote_escape"]="('|%27|\"|\"|%22)"
    ["or_1_1"]="(or.*1.*=.*1|or.*'1'.*=.*'1')"
    ["sleep_benchmark"]="(sleep\(|benchmark\(|waitfor.*delay)"
    ["information_schema"]="information_schema"
    ["concat_function"]="concat\("
    ["hex_encoding"]="(0x[0-9a-f]+|char\()"
    ["stacked_queries"]=".*;.*select"
    ["blind_sqli"]="(and.*1=1|and.*1=2)"
    ["error_based"]="(extractvalue|updatexml|exp\()"
    ["time_based"]="if\(.*sleep"
)

# Output filer
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
REPORT_FILE="sqli_report_${TIMESTAMP}.txt"
HTML_REPORT="sqli_report_${TIMESTAMP}.html"
CSV_REPORT="sqli_report_${TIMESTAMP}.csv"

# Statistik variabler
declare -A ATTACK_COUNTS
declare -A IP_COUNTS
declare -A URL_COUNTS
TOTAL_LINES=0
TOTAL_SUSPICIOUS=0

echo -e "${GREEN}╔════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Apache SQL Injection Detection Tool         ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}\n"

# Funktion til at finde log filer
find_log_file() {
    if [ -n "$1" ] && [ -f "$1" ]; then
        echo "$1"
        return
    fi
    
    for log in "${DEFAULT_LOGS[@]}"; do
        if [ -f "$log" ]; then
            echo "$log"
            return
        fi
    done
    
    return 1
}

# Hent log fil
if [ $# -eq 0 ]; then
    LOG_FILE=$(find_log_file)
    if [ -z "$LOG_FILE" ]; then
        echo -e "${RED}Ingen Apache log fil fundet!${NC}"
        echo -e "Brug: $0 <log_fil>"
        echo -e "\nForventede stier:"
        for log in "${DEFAULT_LOGS[@]}"; do
            echo "  - $log"
        done
        exit 1
    fi
    echo -e "${YELLOW}Bruger log fil: $LOG_FILE${NC}\n"
else
    LOG_FILE=$1
    if [ ! -f "$LOG_FILE" ]; then
        echo -e "${RED}Log fil ikke fundet: $LOG_FILE${NC}"
        exit 1
    fi
fi

# Tjek om vi har læseadgang
if [ ! -r "$LOG_FILE" ]; then
    echo -e "${RED}Ingen læseadgang til $LOG_FILE${NC}"
    echo "Prøv: sudo $0 $LOG_FILE"
    exit 1
fi

echo -e "${BLUE}Analyserer: ${NC}$LOG_FILE"
TOTAL_LINES=$(wc -l < "$LOG_FILE")
echo -e "${BLUE}Total linjer: ${NC}$TOTAL_LINES\n"

# Opret rapport header
cat > "$REPORT_FILE" << EOF
================================================
Apache SQL Injection Detection Report
================================================
Genereret: $(date)
Log Fil: $LOG_FILE
Total Linjer Analyseret: $TOTAL_LINES
================================================

EOF

# CSV header
echo "Timestamp,IP,Method,URL,Pattern,Severity,Full_Request" > "$CSV_REPORT"

# Funktion til at beregne severity
calculate_severity() {
    local pattern_count=$1
    
    if [ $pattern_count -ge 5 ]; then
        echo "CRITICAL"
    elif [ $pattern_count -ge 3 ]; then
        echo "HIGH"
    elif [ $pattern_count -ge 2 ]; then
        echo "MEDIUM"
    else
        echo "LOW"
    fi
}

# Funktion til at parse log linje
parse_log_line() {
    local line="$1"
    local ip=$(echo "$line" | grep -oP '^\S+')
    local timestamp=$(echo "$line" | grep -oP '\[.*?\]' | head -1)
    local method=$(echo "$line" | grep -oP '"\K[A-Z]+')
    local url=$(echo "$line" | grep -oP '"\K[A-Z]+ \K[^"]+' | cut -d' ' -f1)
    local status=$(echo "$line" | grep -oP '" \K\d{3}')
    
    echo "$ip|$timestamp|$method|$url|$status"
}

# Analyser log fil
echo -e "${CYAN}Scanning for SQL Injection patterns...${NC}\n"

declare -a SUSPICIOUS_ENTRIES

while IFS= read -r line; do
    # Konverter til lowercase for case-insensitive matching
    line_lower=$(echo "$line" | tr '[:upper:]' '[:lower:]')
    
    matches=0
    matched_patterns=""
    
    # Tjek hver pattern
    for pattern_name in "${!SQLI_PATTERNS[@]}"; do
        pattern="${SQLI_PATTERNS[$pattern_name]}"
        
        if echo "$line_lower" | grep -qiP "$pattern"; then
            matches=$((matches + 1))
            matched_patterns="$matched_patterns,$pattern_name"
            ATTACK_COUNTS[$pattern_name]=$((${ATTACK_COUNTS[$pattern_name]:-0} + 1))
        fi
    done
    
    # Hvis der er matches, log det
    if [ $matches -gt 0 ]; then
        TOTAL_SUSPICIOUS=$((TOTAL_SUSPICIOUS + 1))
        
        # Parse log linje
        IFS='|' read -r ip timestamp method url status <<< "$(parse_log_line "$line")"
        
        # Opdater statistik
        IP_COUNTS[$ip]=$((${IP_COUNTS[$ip]:-0} + 1))
        URL_COUNTS[$url]=$((${URL_COUNTS[$url]:-0} + 1))
        
        # Beregn severity
        severity=$(calculate_severity $matches)
        
        # Farve baseret på severity
        case $severity in
            CRITICAL) color=$RED ;;
            HIGH) color=$MAGENTA ;;
            MEDIUM) color=$YELLOW ;;
            LOW) color=$CYAN ;;
        esac
        
        # Print til console
        echo -e "${color}[$severity]${NC} $ip - $method $url"
        echo -e "  Patterns: ${matched_patterns:1}"
        echo -e "  Time: $timestamp\n"
        
        # Gem til rapport
        cat >> "$REPORT_FILE" << EOF
[$severity] Suspicious Activity Detected
IP Address: $ip
Timestamp: $timestamp
Method: $method
URL: $url
HTTP Status: $status
Matched Patterns: ${matched_patterns:1}
Pattern Count: $matches
Full Request: $line
----------------------------------------
EOF
        
        # Gem til CSV (escape quotes)
        escaped_line=$(echo "$line" | sed 's/"/""/g')
        echo "\"$timestamp\",\"$ip\",\"$method\",\"$url\",\"${matched_patterns:1}\",\"$severity\",\"$escaped_line\"" >> "$CSV_REPORT"
        
        SUSPICIOUS_ENTRIES+=("$severity|$ip|$url|$matches|${matched_patterns:1}")
    fi
done < "$LOG_FILE"

# Generer statistik
echo -e "\n${GREEN}╔════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              Analysis Summary                  ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}\n"

echo -e "${BLUE}Total Suspicious Requests:${NC} $TOTAL_SUSPICIOUS ($(awk "BEGIN {printf \"%.2f\", ($TOTAL_SUSPICIOUS/$TOTAL_LINES)*100}")%)"

# Tilføj til rapport
cat >> "$REPORT_FILE" << EOF

================================================
SUMMARY STATISTICS
================================================
Total Lines Analyzed: $TOTAL_LINES
Suspicious Requests: $TOTAL_SUSPICIOUS
Detection Rate: $(awk "BEGIN {printf \"%.2f\", ($TOTAL_SUSPICIOUS/$TOTAL_LINES)*100}")%

================================================
ATTACK PATTERN BREAKDOWN
================================================
EOF

echo -e "\n${YELLOW}Attack Pattern Breakdown:${NC}"
for pattern in "${!ATTACK_COUNTS[@]}"; do
    count=${ATTACK_COUNTS[$pattern]}
    echo -e "  ${CYAN}$pattern:${NC} $count"
    echo "$pattern: $count" >> "$REPORT_FILE"
done

# Top angribende IP'er
cat >> "$REPORT_FILE" << EOF

================================================
TOP ATTACKING IP ADDRESSES
================================================
EOF

echo -e "\n${YELLOW}Top 10 Attacking IPs:${NC}"
for ip in "${!IP_COUNTS[@]}"; do
    echo "${IP_COUNTS[$ip]} $ip"
done | sort -rn | head -10 | while read count ip; do
    echo -e "  ${RED}$ip:${NC} $count attempts"
    echo "$ip: $count attempts" >> "$REPORT_FILE"
done

# Top targeted URLs
cat >> "$REPORT_FILE" << EOF

================================================
TOP TARGETED URLs
================================================
EOF

echo -e "\n${YELLOW}Top 10 Targeted URLs:${NC}"
for url in "${!URL_COUNTS[@]}"; do
    echo "${URL_COUNTS[$url]} $url"
done | sort -rn | head -10 | while read count url; do
    echo -e "  ${MAGENTA}$url:${NC} $count attempts"
    # Truncate long URLs for file
    url_truncated=$(echo "$url" | cut -c1-80)
    echo "$url_truncated: $count attempts" >> "$REPORT_FILE"
done

# Generer HTML rapport
cat > "$HTML_REPORT" << 'HTMLEOF'
<!DOCTYPE html>
<html lang="da">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SQL Injection Detection Report</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 20px;
            background: #1a1a1a;
            color: #e0e0e0;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: #2d2d2d;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 0 20px rgba(0,0,0,0.5);
        }
        h1 {
            color: #00ff00;
            border-bottom: 3px solid #00ff00;
            padding-bottom: 10px;
        }
        h2 {
            color: #ff6b6b;
            margin-top: 30px;
        }
        .stat-box {
            background: #1a1a1a;
            padding: 20px;
            margin: 20px 0;
            border-left: 4px solid #00ff00;
            border-radius: 5px;
        }
        .critical { color: #ff0000; font-weight: bold; }
        .high { color: #ff6b6b; font-weight: bold; }
        .medium { color: #ffa500; }
        .low { color: #ffff00; }
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
            background: #1a1a1a;
        }
        th {
            background: #00ff00;
            color: #000;
            padding: 12px;
            text-align: left;
        }
        td {
            padding: 10px;
            border-bottom: 1px solid #444;
        }
        tr:hover {
            background: #3d3d3d;
        }
        .pattern-badge {
            display: inline-block;
            background: #444;
            padding: 3px 8px;
            margin: 2px;
            border-radius: 3px;
            font-size: 0.85em;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🛡️ SQL Injection Detection Report</h1>
        <div class="stat-box">
            <strong>Generated:</strong> TIMESTAMP_PLACEHOLDER<br>
            <strong>Log File:</strong> LOGFILE_PLACEHOLDER<br>
            <strong>Total Lines:</strong> TOTALLINES_PLACEHOLDER<br>
            <strong>Suspicious Requests:</strong> SUSPICIOUS_PLACEHOLDER
        </div>
HTMLEOF

# Tilføj dynamisk data til HTML
sed -i "s|TIMESTAMP_PLACEHOLDER|$(date)|g" "$HTML_REPORT"
sed -i "s|LOGFILE_PLACEHOLDER|$LOG_FILE|g" "$HTML_REPORT"
sed -i "s|TOTALLINES_PLACEHOLDER|$TOTAL_LINES|g" "$HTML_REPORT"
sed -i "s|SUSPICIOUS_PLACEHOLDER|$TOTAL_SUSPICIOUS|g" "$HTML_REPORT"

# Tilføj attack patterns til HTML
cat >> "$HTML_REPORT" << EOF
        <h2>Attack Pattern Breakdown</h2>
        <table>
            <tr><th>Pattern</th><th>Count</th></tr>
EOF

for pattern in "${!ATTACK_COUNTS[@]}"; do
    count=${ATTACK_COUNTS[$pattern]}
    echo "            <tr><td>$pattern</td><td>$count</td></tr>" >> "$HTML_REPORT"
done

echo "        </table>" >> "$HTML_REPORT"

# Afslut HTML
cat >> "$HTML_REPORT" << 'EOF'
    </div>
</body>
</html>
EOF

# Anbefalinger
cat >> "$REPORT_FILE" << EOF

================================================
SECURITY RECOMMENDATIONS
================================================
1. Block or rate-limit suspicious IP addresses
2. Implement Web Application Firewall (WAF)
3. Update and patch web applications
4. Use prepared statements/parameterized queries
5. Implement input validation and sanitization
6. Enable SQL injection detection in mod_security
7. Review and secure vulnerable endpoints
8. Consider implementing CAPTCHA on forms

================================================
IMMEDIATE ACTIONS
================================================
EOF

echo -e "\n${RED}╔════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║           Security Recommendations             ║${NC}"
echo -e "${RED}╚════════════════════════════════════════════════╝${NC}\n"

if [ $TOTAL_SUSPICIOUS -gt 0 ]; then
    echo -e "${YELLOW}⚠ Immediate Actions Required:${NC}"
    echo "1. Review suspicious IPs and consider blocking"
    echo "2. Check vulnerable endpoints for SQL injection flaws"
    echo "3. Implement WAF rules to block detected patterns"
    echo "4. Update web applications and frameworks"
    echo ""
    
    # Generer iptables blokering script
    BLOCK_SCRIPT="block_sqli_ips_${TIMESTAMP}.sh"
    echo "#!/bin/bash" > "$BLOCK_SCRIPT"
    echo "# Auto-generated IP blocking script" >> "$BLOCK_SCRIPT"
    echo "# Generated: $(date)" >> "$BLOCK_SCRIPT"
    echo "" >> "$BLOCK_SCRIPT"
    
    echo -e "${CYAN}Generating IP block script...${NC}"
    for ip in "${!IP_COUNTS[@]}"; do
        count=${IP_COUNTS[$ip]}
        if [ $count -ge 5 ]; then
            echo "iptables -A INPUT -s $ip -j DROP  # $count attempts" >> "$BLOCK_SCRIPT"
            echo "Block $ip (High activity: $count attempts)" >> "$REPORT_FILE"
        fi
    done
    chmod +x "$BLOCK_SCRIPT"
    
    echo -e "${GREEN}✓ IP block script created: $BLOCK_SCRIPT${NC}"
fi

# Afslutning
echo -e "\n${GREEN}╔════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              Reports Generated                 ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}\n"

echo -e "${CYAN}📄 Text Report:${NC} $REPORT_FILE"
echo -e "${CYAN}📊 HTML Report:${NC} $HTML_REPORT"
echo -e "${CYAN}📈 CSV Export:${NC} $CSV_REPORT"
if [ -f "$BLOCK_SCRIPT" ]; then
    echo -e "${CYAN}🛡️ Block Script:${NC} $BLOCK_SCRIPT"
fi

echo -e "\n${YELLOW}View HTML report with:${NC} firefox $HTML_REPORT"
echo -e "${YELLOW}Block IPs with:${NC} sudo ./$BLOCK_SCRIPT\n"

echo -e "${GREEN}Analysis complete!${NC}"

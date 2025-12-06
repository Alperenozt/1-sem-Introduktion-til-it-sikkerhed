#!/bin/bash

# Script til at tjekke SSH authorized_keys filer
# Forfatter: [Dit navn]
# Dato: $(date +%Y-%m-%d)

echo "SSH Nøgler Tjekker"
echo "=================="
echo "Tjekker alle brugeres .ssh/authorized_keys filer..."

echo ""
echo "🔍 SCANNER BRUGERE..."
echo "==================="

# Tæller
total_brugere=0
brugere_med_ssh=0
total_noegler=0

# Gennemgå alle brugere fra /etc/passwd
while IFS=':' read -r username x uid gid comment homedir shell; do
    total_brugere=$((total_brugere + 1))
    
    # Spring system-brugere over (UID < 1000)
    if [ "$uid" -lt 1000 ] && [ "$uid" -ne 0 ]; then
        continue
    fi
    
    # Tjek om hjemmemappe findes
    if [ ! -d "$homedir" ]; then
        continue
    fi
    
    ssh_dir="$homedir/.ssh"
    auth_keys="$ssh_dir/authorized_keys"
    
    echo ""
    echo "👤 BRUGER: $username"
    echo "   UID: $uid"
    echo "   Hjemmemappe: $homedir"
    
    # Tjek om .ssh mappe findes
    if [ -d "$ssh_dir" ]; then
        echo "   📁 .ssh mappe: ✅ Findes"
        
        # Tjek tilladelser på .ssh mappe
        ssh_perms=$(stat -c "%a" "$ssh_dir" 2>/dev/null)
        if [ "$ssh_perms" = "700" ]; then
            echo "   🔒 .ssh tilladelser: ✅ Sikker ($ssh_perms)"
        else
            echo "   ⚠️  .ssh tilladelser: ⚠️  Usikker ($ssh_perms) - bør være 700"
        fi
        
        # Tjek om authorized_keys findes
        if [ -f "$auth_keys" ]; then
            brugere_med_ssh=$((brugere_med_ssh + 1))
            echo "   🔑 authorized_keys: ✅ Findes"
            
            # Tjek tilladelser på authorized_keys
            keys_perms=$(stat -c "%a" "$auth_keys" 2>/dev/null)
            if [ "$keys_perms" = "600" ] || [ "$keys_perms" = "644" ]; then
                echo "   🔒 Keys tilladelser: ✅ OK ($keys_perms)"
            else
                echo "   ⚠️  Keys tilladelser: ⚠️  Usikker ($keys_perms) - bør være 600"
            fi
            
            # Tæl antal nøgler
            if [ -r "$auth_keys" ]; then
                antal_keys=$(grep -c "^ssh-" "$auth_keys" 2>/dev/null || echo "0")
                total_noegler=$((total_noegler + antal_keys))
                echo "   📊 Antal SSH nøgler: $antal_keys"
                
                if [ "$antal_keys" -gt 0 ]; then
                    echo "   🔍 NØGLE DETALJER:"
                    
                    # Vis hver nøgle
                    grep "^ssh-" "$auth_keys" | while read key; do
                        key_type=$(echo "$key" | awk '{print $1}')
                        key_comment=$(echo "$key" | awk '{for(i=3;i<=NF;i++) printf "%s ", $i; print ""}' | sed 's/ $//')
                        
                        echo "      • Type: $key_type"
                        if [ -n "$key_comment" ]; then
                            echo "        Kommentar: $key_comment"
                        else
                            echo "        Kommentar: Ingen"
                        fi
                    done
                fi
            else
                echo "   ❌ Kan ikke læse authorized_keys (mangler rettigheder)"
            fi
        else
            echo "   📝 authorized_keys: ❌ Findes ikke"
        fi
    else
        echo "   📁 .ssh mappe: ❌ Findes ikke"
    fi
    
done < /etc/passwd

echo ""
echo ""
echo "📊 SAMMENDRAG:"
echo "============="
echo "Totale brugere tjekket: $total_brugere"
echo "Brugere med SSH nøgler: $brugere_med_ssh"
echo "Totale SSH nøgler: $total_noegler"

# Sikkerhedsanbefalinger
echo ""
echo "🔒 SIKKERHEDSANBEFALINGER:"
echo "========================="
echo "1. .ssh mappe skal have tilladelser 700:"
echo "   chmod 700 ~/.ssh"
echo ""
echo "2. authorized_keys skal have tilladelser 600:"
echo "   chmod 600 ~/.ssh/authorized_keys"
echo ""
echo "3. Fjern ukendte eller gamle nøgler:"
echo "   nano ~/.ssh/authorized_keys"
echo ""
echo "4. Overvåg regelmæssigt for nye/ændrede nøgler"

# Find mistænkelige ting
echo ""
echo "🚨 SIKKERHEDSTJEK:"
echo "================="

mistænkeligt_fundet=false

# Tjek for root SSH nøgler
if [ -f "/root/.ssh/authorized_keys" ]; then
    root_keys=$(grep -c "^ssh-" /root/.ssh/authorized_keys 2>/dev/null || echo "0")
    if [ "$root_keys" -gt 0 ]; then
        echo "⚠️  ROOT har $root_keys SSH nøgler - tjek grundigt!"
        mistænkeligt_fundet=true
    fi
fi

# Tjek for world-writable SSH filer
world_writable=$(find /home -name ".ssh" -type d -perm -002 2>/dev/null)
if [ -n "$world_writable" ]; then
    echo "🚨 FARLIGE .ssh mapper (world-writable):"
    echo "$world_writable"
    mistænkeligt_fundet=true
fi

world_writable_keys=$(find /home -name "authorized_keys" -type f -perm -002 2>/dev/null)
if [ -n "$world_writable_keys" ]; then
    echo "🚨 FARLIGE authorized_keys filer (world-writable):"
    echo "$world_writable_keys"
    mistænkeligt_fundet=true
fi

if [ "$mistænkeligt_fundet" = false ]; then
    echo "✅ Ingen umiddelbare sikkerhedsproblemer fundet"
fi

echo ""
echo "💡 HVAD ER SSH NØGLER?"
echo "======================"
echo "SSH nøgler tillader passwordløs login til servere"
echo "authorized_keys = liste over tillatte offentlige nøgler"
echo "Hvis en hacker får adgang til denne fil, kan de logge ind!"

echo ""
echo "Script afsluttet: $(date)"

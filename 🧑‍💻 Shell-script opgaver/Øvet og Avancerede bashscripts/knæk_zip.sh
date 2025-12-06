#!/bin/bash

# Script til ZIP password cracking (kun til egen brug/uddannelse)
# Forfatter: [Dit navn]
# Dato: $(date +%Y-%m-%d)

echo "ZIP Password Cracker (Educational)"
echo "=================================="
echo "⚠️  KUN til egne filer og uddannelsesformål!"

# Tjek om zip findes
if ! command -v unzip &> /dev/null; then
    echo "❌ unzip ikke installeret!"
    echo "Installer med: sudo apt install unzip"
    exit 1
fi

# Spørg om ZIP-fil
echo ""
echo "Indtast sti til ZIP-fil:"
read zip_fil

# Tjek om ZIP-filen findes
if [ ! -f "$zip_fil" ]; then
    echo "❌ ZIP-fil ikke fundet: $zip_fil"
    
    echo ""
    echo "💡 Vil du oprette en test ZIP-fil? (y/n)"
    read create_test
    
    if [ "$create_test" = "y" ]; then
        echo "Opretter test.zip med password 'secret123'..."
        echo "Dette er hemmeligt indhold!" > test_content.txt
        zip -P "secret123" test.zip test_content.txt
        rm test_content.txt
        zip_fil="test.zip"
        echo "✅ Test ZIP oprettet: $zip_fil"
        echo "Password er: secret123"
    else
        exit 1
    fi
fi

# Spørg om ordliste
echo ""
echo "Indtast sti til ordliste (eller tryk Enter for standard):"
read ordliste

# Standard ordliste eller opret simpel en
if [ -z "$ordliste" ]; then
    # Opret simpel ordliste
    ordliste="passwords.txt"
    echo "Opretter simpel ordliste: $ordliste"
    
    cat > "$ordliste" << 'EOF'
123456
password
123123
admin
root
test
qwerty
abc123
password123
secret
secret123
admin123
user
guest
login
pass
EOF
    
    echo "✅ Ordliste oprettet med almindelige passwords"
fi

# Tjek om ordlisten findes
if [ ! -f "$ordliste" ]; then
    echo "❌ Ordliste ikke fundet: $ordliste"
    exit 1
fi

echo ""
echo "🎯 ZIP-fil: $zip_fil"
echo "📝 Ordliste: $ordliste"
echo "📊 Passwords at teste: $(wc -l < "$ordliste")"

echo ""
echo "🚀 STARTER BRUTE FORCE..."
echo "========================"

# Tæller
attempts=0
start_tid=$(date +%s)

# Læs hver linje i ordlisten
while IFS= read -r password; do
    attempts=$((attempts + 1))
    
    # Vis progress hvert 10. forsøg
    if [ $((attempts % 10)) -eq 0 ]; then
        echo "Forsøg $attempts: Tester '$password'..."
    fi
    
    # Test passwordet (med bedre error handling)
    # Fjern whitespace fra password
    password=$(echo "$password" | tr -d '[:space:]')
    
    # Skip tomme linjer
    if [ -z "$password" ]; then
        continue
    fi
    
    # Test passwordet
    if unzip -P"$password" -t "$zip_fil" >/dev/null 2>&1; then
        slut_tid=$(date +%s)
        tid_brugt=$((slut_tid - start_tid))
        
        echo ""
        echo "🎉 SUCCESS!"
        echo "=========="
        echo "Password fundet: '$password'"
        echo "Forsøg brugt: $attempts"
        echo "Tid brugt: ${tid_brugt} sekunder"
        
        # Udpak filen
        echo ""
        echo "💾 Udpakker filer..."
        output_dir="udpakket_$(date +%H%M%S)"
        unzip -P"$password" "$zip_fil" -d "$output_dir"
        echo "✅ Filer udpakket til mappen: $output_dir"
        
        exit 0
    fi
    
done < "$ordliste"

# Hvis ingen passwords virkede
slut_tid=$(date +%s)
tid_brugt=$((slut_tid - start_tid))

echo ""
echo "❌ INGEN SUCCESS"
echo "==============="
echo "Passwords testet: $attempts"
echo "Tid brugt: ${tid_brugt} sekunder"
echo "Passwordet er ikke i ordlisten"

echo ""
echo "💡 NÆSTE SKRIDT:"
echo "==============="
echo "1. Prøv større ordliste:"
echo "   - /usr/share/wordlists/rockyou.txt (hvis installeret)"
echo "   - /usr/share/dict/words"
echo "2. Prøv avancerede værktøjer:"
echo "   - john the ripper"
echo "   - hashcat"
echo "   - fcrackzip"

echo ""
echo "🔧 PROFESSIONELLE VÆRKTØJER:"
echo "=========================="
echo "# Installer fcrackzip:"
echo "sudo apt install fcrackzip"
echo ""
echo "# Brug fcrackzip:"
echo "fcrackzip -u -D -p $ordliste $zip_fil"
echo ""
echo "# Installer john:"
echo "sudo apt install john"
echo ""
echo "# Konverter ZIP til john format:"
echo "zip2john $zip_fil > hash.txt"
echo "john --wordlist=$ordliste hash.txt"

echo ""
echo "⚖️  ETIK OG LOVGIVNING:"
echo "======================"
echo "- Brug KUN på egne filer!"
echo "- Educational/cybersecurity formål"
echo "- Respekter andres privatliv"
echo "- Kend din lokale lovgivning"

echo ""
echo "Script afsluttet: $(date)"

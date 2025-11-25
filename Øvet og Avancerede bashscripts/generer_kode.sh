#!/bin/bash

# Script til generering af tilfældige adgangskoder
# Forfatter: [Dit navn]
# Dato: $(date +%Y-%m-%d)

echo "Tilfældig Adgangskode Generator"
echo "=============================="

# Standard længde
DEFAULT_LENGTH=16

# Spørg brugeren om længde
echo "Indtast ønsket længde (tryk Enter for $DEFAULT_LENGTH tegn):"
read length

# Hvis ingen input, brug standard
if [ -z "$length" ]; then
    length=$DEFAULT_LENGTH
fi

# Valider at input er et tal
if ! [[ "$length" =~ ^[0-9]+$ ]] || [ "$length" -lt 1 ]; then
    echo "❌ FEJL: Indtast et gyldigt tal større end 0"
    exit 1
fi

echo ""
echo "Genererer adgangskode med $length tegn..."
echo ""

# Metode 1: Brug /dev/urandom med tr (mest sikker)
echo "🔐 Metode 1 - Alfanumerisk + specialtegn:"
echo "========================================"
password1=$(tr -dc 'A-Za-z0-9!@#$%^&*()_+-=[]{}|;:,.<>?' < /dev/urandom | head -c $length)
echo "Password: $password1"

echo ""

# Metode 2: Kun alfanumeriske tegn (nemmere at huske/skrive)
echo "🔤 Metode 2 - Kun bogstaver og tal:"
echo "=================================="
password2=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c $length)
echo "Password: $password2"

echo ""

# Metode 3: Brug openssl (hvis tilgængelig)
if command -v openssl &> /dev/null; then
    echo "🔒 Metode 3 - OpenSSL baseret:"
    echo "============================="
    password3=$(openssl rand -base64 $((length * 3 / 4)) | tr -d "=+/" | cut -c1-$length)
    echo "Password: $password3"
    echo ""
fi

# Metode 4: Brug shuf med ordliste (hvis tilgængelig)
if command -v shuf &> /dev/null && [ -f /usr/share/dict/words ]; then
    echo "📚 Metode 4 - Ord-baseret (mere husbar):"
    echo "======================================="
    # Generer 3-4 korte ord
    word_count=$((length / 4 + 1))
    password4=$(shuf -n $word_count /usr/share/dict/words | tr -d '\n' | cut -c1-$length)
    echo "Password: $password4"
    echo ""
fi

# Metode 5: Brug pwgen (hvis installeret)
if command -v pwgen &> /dev/null; then
    echo "⚡ Metode 5 - Pwgen (professionel):"
    echo "================================="
    echo "Secure passwords:"
    pwgen -s $length 5
    echo ""
    echo "Pronounceable passwords:"
    pwgen $length 5
    echo ""
fi

# Password styrke analyse
echo "💪 Password Styrke Tips:"
echo "======================="
echo "✅ Længde: $length tegn (anbefalet minimum: 12)"

# Tjek om der er store bogstaver, små bogstaver, tal og specialtegn
if [[ "$password1" =~ [A-Z] ]]; then
    echo "✅ Indeholder store bogstaver"
else
    echo "⚠️  Mangler store bogstaver"
fi

if [[ "$password1" =~ [a-z] ]]; then
    echo "✅ Indeholder små bogstaver"
else
    echo "⚠️  Mangler små bogstaver"
fi

if [[ "$password1" =~ [0-9] ]]; then
    echo "✅ Indeholder tal"
else
    echo "⚠️  Mangler tal"
fi

if [[ "$password1" =~ [^A-Za-z0-9] ]]; then
    echo "✅ Indeholder specialtegn"
else
    echo "⚠️  Mangler specialtegn"
fi

echo ""
echo "🎲 Tilfældige fakta:"
echo "=================="
echo "Antal mulige kombinationer (alfanumerisk): $((62**length))"
echo "Tid at knække med brute force: Flere billioner år!"

echo ""
echo "💡 Sikkerhedstips:"
echo "=================="
echo "- Brug aldrig samme password to steder"
echo "- Aktiver 2FA hvor muligt"
echo "- Brug en password manager"
echo "- Skift passwords regelmæssigt"
echo "- Gem aldrig passwords i plain text"

echo ""
echo "Generering afsluttet: $(date)"
